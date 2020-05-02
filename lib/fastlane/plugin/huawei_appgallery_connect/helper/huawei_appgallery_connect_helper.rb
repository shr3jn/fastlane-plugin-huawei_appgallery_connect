require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class HuaweiAppgalleryConnectHelper
      def self.get_token(client_id, client_secret)
        UI.important("Fetching app access token")

        uri = URI('https://connect-api.cloud.huawei.com/api/oauth2/v1/token')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req.body = {client_id: client_id, grant_type: 'client_credentials', client_secret: client_secret }.to_json
        res = http.request(req)

        result_json = JSON.parse(res.body)

        return result_json['access_token']
      end

      def self.get_app_info(token, client_id, app_id)
        UI.message("Fetching App Info")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-info?appId=#{app_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        response = http.request(request)
        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot obtain app info, please check API Token / Permissions (status code: #{response.code})")
          return false
        end
        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          UI.success("Successfully getting app info")
          return result_json['appInfo']
        else
          UI.user_error!("Failed to get app info")
        end

      end

      def self.update_appinfo(client_id, token, app_id, privacy_policy_url)
        UI.important("Updating app info")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-info?appId=#{app_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"

        request.body = {privacyPolicy: privacy_policy_url}.to_json

        response = http.request(request)
        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot update app info, please check API Token / Permissions (status code: #{response.code})")
          return false
        end
        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          UI.success("Successfully updated app info")
        else
          UI.user_error!("Failed to update app info")
        end
      end


      def self.upload_app(token, client_id, app_id, apk_path)
        UI.message("Fetching upload URL")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/upload-url?appId=#{app_id}&suffix=apk")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot obtain upload url, please check API Token / Permissions (status code: #{response.code})")
          return false
        end

        result_json = JSON.parse(response.body)

        if result_json['uploadUrl'].nil?
          UI.user_error!('Cannot obtain upload url')
          return false
        else
          UI.important('Uploading app')
          # Upload App
          boundary = "755754302457647"
          uri = URI(result_json['uploadUrl'])
          # uri = URI("http://localhost/dashboard/test")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Post.new(uri)

          form_data = [['file', File.open(apk_path.to_s)],['authCode', result_json['authCode']],['fileCount', '1']]
          request.set_form form_data, 'multipart/form-data'

          result = http.request(request)
          if !result.kind_of? Net::HTTPSuccess
            UI.user_error!("Cannot upload app, please check API Token / Permissions (status code: #{result.code})")
            return false
          end
          result_json = JSON.parse(result.body)

          if result_json['result']['result_code'].to_i == 0
            UI.success('Upload app to AppGallery Connect successful')
            UI.important("Saving app information")

            uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=#{app_id}")

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Put.new(uri.request_uri)
            request["client_id"] = client_id
            request["Authorization"] = "Bearer #{token}"

            data = {fileType: 5, files: [{

                fileName: "release.apk",
                fileDestUrl: result_json['result']['UploadFileRsp']['fileInfoList'][0]['fileDestUlr'],
                size: result_json['result']['UploadFileRsp']['fileInfoList'][0]['size'].to_s

            }] }.to_json

            request.body = data
            response = http.request(request)
            if !response.kind_of? Net::HTTPSuccess
              UI.user_error!("Cannot save app info, please check API Token / Permissions (status code: #{response.code})")
              return false
            end
            result_json = JSON.parse(response.body)

            if result_json['ret']['code'] == 0
              UI.success("App information saved.")
              return true
            else
              UI.user_error!(result_json)
              UI.user_error!("Failed to save app information")
              return false
            end
          else
            return false
          end
        end
      end

      def self.submit_app_for_review(token, params)
        UI.important("Submitting app for review")

        release_type = ''
        release_time = ''

        if (params[:phase_wise_release] != nil && params[:phase_wise_release]) && (
              params[:phase_release_start_time] == nil ||
              params[:phase_release_end_time] == nil ||
              params[:phase_release_percent] == nil ||
              params[:phase_release_description] == nil
        )
          UI.user_error!("Submit for review failed. Phase wise release requires Start time, End time Release Percent & Descrption")
          return
        elsif params[:phase_wise_release] != nil && params[:phase_wise_release]
          release_type = '&releaseType=3'
        end

        if params[:release_time] != nil
          params[:release_time] = URI::encode(params[:release_time], /\W/)
          release_time = "&releaseTime=#{params[:release_time]}"
        end

        changelog = ''

        if params[:changelog_path] != nil
          changelog_data = File.read(params[:changelog_path])

          if changelog_data.length < 3 || changelog_data.length > 300
            UI.user_error!("Failed to submit app for review. Changelog file length is invalid")
            return
          else
            changelog = "&remark=" + URI::encode(changelog_data)
          end
        end

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-submit?appId=#{params[:app_id]}" + changelog + release_type + release_time)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["client_id"] = params[:client_id]
        request["Authorization"] = "Bearer #{token}"

        if params[:phase_wise_release] != nil && params[:phase_wise_release]
          request.body = {
              phasedReleaseStartTime: params[:phase_release_start_time],
              phasedReleaseEndTime: params[:phase_release_end_time],
              phasedReleasePercent: params[:phase_release_percent],
              phasedReleaseDescription: params[:phase_release_description]
          }.to_json
        end


        response = http.request(request)

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
            UI.success("Successfully submitted app for review")
        else
          UI.user_error!("Failed to submit app for review")
        end

      end
    end
  end
end
