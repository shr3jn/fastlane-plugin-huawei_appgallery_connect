require 'fastlane_core/ui/ui'
require 'cgi'
require 'time'

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

      def self.get_app_id(token, client_id, package_id)
        UI.message("Fetching App ID")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/appid-list?packageName=#{package_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        response = http.request(request)
        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot obtain app id, please check API Token / Permissions (status code: #{response.code})")
          return false
        end
        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          UI.success("Successfully getting app id")
          return result_json['appids'][0]['value']
        else
          UI.user_error!(result_json)
          UI.user_error!("Failed to get app id")
        end

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
          UI.user_error!(result_json)
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
        request["Content-Type"] = "application/json"

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
          UI.user_error!(result_json)
          UI.user_error!("Failed to update app info")
        end
      end


      def self.upload_app(token, client_id, app_id, apk_path, is_aab)
        UI.message("Fetching upload URL")

        responseData = JSON.parse("{}")
        responseData["success"] = false
        responseData["code"] = 0

        file_size_in_bytes = File.size(apk_path.to_s)
        sha256 = Digest::SHA256.file(apk_path).hexdigest

        if(is_aab)
          uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/upload-url/for-obs?appId=#{app_id}&fileName=release.aab&contentLength=#{file_size_in_bytes}&suffix=aab")
          upload_filename = "release.aab"
        else
          uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/upload-url/for-obs?appId=#{app_id}&fileName=release.apk&contentLength=#{file_size_in_bytes}&suffix=apk")
          upload_filename = "release.apk"
        end

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot obtain upload url, please check API Token / Permissions (status code: #{response.code})")
          responseData["success"] = false
          return responseData
        end

        result_json = JSON.parse(response.body)

        if result_json.nil? || result_json['urlInfo'].nil? || result_json['urlInfo']['url'].nil?
          UI.message('Cannot obtain upload url')
          UI.user_error!(response.body)

          responseData["success"] = false
          return responseData
        else
          UI.important('Uploading app')
          # Upload App
          boundary = "755754302457647"
          uri = URI(result_json['urlInfo']['url'])
          # uri = URI("http://localhost/dashboard/test")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Put.new(uri)
          request["Authorization"] = result_json['urlInfo']['headers']['Authorization']
          request["Content-Type"] = result_json['urlInfo']['headers']['Content-Type']
          request["user-agent"] = result_json['urlInfo']['headers']['user-agent']
          request["Host"] = result_json['urlInfo']['headers']['Host']
          request["x-amz-date"] = result_json['urlInfo']['headers']['x-amz-date']
          request["x-amz-content-sha256"] = result_json['urlInfo']['headers']['x-amz-content-sha256']

          request.body = File.read(apk_path.to_s)
          request.content_type = 'application/octet-stream'

          result = http.request(request)
          if !result.kind_of? Net::HTTPSuccess
            UI.user_error!(result.body)
            UI.user_error!("Cannot upload app, please check API Token / Permissions (status code: #{result.code})")
            responseData["success"] = false
            return responseData
          end

          if result.code.to_i == 200
            UI.success('Upload app to AppGallery Connect successful')
            UI.important("Saving app information")

            uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=#{app_id}")

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Put.new(uri.request_uri)
            request["client_id"] = client_id
            request["Authorization"] = "Bearer #{token}"
            request["Content-Type"] = "application/json"

            data = {fileType: 5, files: [{

                fileName: upload_filename,
                fileDestUrl: result_json['urlInfo']['objectId']
                # size: result_json['result']['UploadFileRsp']['fileInfoList'][0]['size'].to_s

            }] }.to_json

            request.body = data
            response = http.request(request)
            if !response.kind_of? Net::HTTPSuccess
              UI.user_error!("Cannot save app info, please check API Token / Permissions (status code: #{response.code})")
              responseData["success"] = false
              return responseData
            end
            result_json = JSON.parse(response.body)

            if result_json['ret']['code'] == 0
              UI.success("App information saved.")
              responseData["success"] = true
              responseData["pkgVersion"] = result_json["pkgVersion"][0]
              return responseData
            else
              UI.user_error!(result_json)
              UI.user_error!("Failed to save app information")
              responseData["success"] = false
              return responseData
            end
          else
            responseData["success"] = false
            return responseData
          end
        end
      end

      def self.query_aab_compilation_status(token,params, pkgVersion)
        UI.important("Checking aab compilation status")
        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/aab/complile/status?appId=#{params[:app_id]}&pkgIds=#{pkgVersion}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Get.new(uri.request_uri)
        request["client_id"] = params[:client_id]
        request["Authorization"] = "Bearer #{token}"

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot query compilation status (status code: #{response.code}, body: #{response.body})")
          return false
        end

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          return result_json['pkgStateList'][0]['aabCompileStatus']
        else
          UI.user_error!(result_json)
          return -999
        end
      end

      def self.submit_app_for_review(token, params)
        UI.important("Submitting app for review")

        release_type = ''
        release_time = ''
        test_config = {}

        # Handle open testing configuration
        if params[:use_testing_version]
          UI.important("Configuring open testing")
          test_config = prepare_test_config(params)
          release_type = '&releaseType=1' # Open testing release type
        elsif (params[:phase_wise_release] != nil && params[:phase_wise_release]) && (
              params[:phase_release_start_time] == nil ||
              params[:phase_release_end_time] == nil ||
              params[:phase_release_percent] == nil ||
              params[:phase_release_description] == nil
        )
          UI.user_error!("Submit for review failed. Phase wise release requires Start time, End time Release Percent & Description")
          return
        elsif params[:phase_wise_release] != nil && params[:phase_wise_release]
          release_type = '&releaseType=3'
        end

        if params[:release_time] != nil
          params[:release_time] = CGI.escape(params[:release_time])
          release_time = "&releaseTime=#{params[:release_time]}"
        end

        changelog = ''

        if params[:changelog_path] != nil
          changelog_data = File.read(params[:changelog_path])

          if changelog_data.length < 3 || changelog_data.length > 500
            UI.user_error!("Failed to submit app for review. Changelog file length is invalid")
            return
          else
            changelog = "&remark=" + CGI.escape(changelog_data)
          end
        end

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-submit?appId=#{params[:app_id]}" + changelog + release_type + release_time)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["client_id"] = params[:client_id]
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"

        if params[:phase_wise_release] != nil && params[:phase_wise_release]
          request.body = {
              phasedReleaseStartTime: params[:phase_release_start_time],
              phasedReleaseEndTime: params[:phase_release_end_time],
              phasedReleasePercent: params[:phase_release_percent],
              phasedReleaseDescription: params[:phase_release_description]
          }.to_json
        elsif params[:use_testing_version]
          test_config[:releaseType] = 1  # Explicitly set release type for open testing
          request.body = test_config.to_json
        end

        UI.important("Request URL: #{uri.to_s}")
        UI.important("Request Body: #{request.body}")

        response = http.request(request)

        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot submit app for review (status code: #{response.code}, body: #{response.body})")
          return false
        end

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          UI.success("Successfully submitted app for review")
        elsif result_json['ret']['code'] == 204144660 && result_json['ret']['msg'].include?("It may take 2-5 minutes")
          UI.important(result_json)
          UI.important("Build is currently processing, waiting for 2 minutes before submitting again...")
          sleep(120)
          self.submit_app_for_review(token, params)
        else
          UI.user_error!(result_json)
          UI.user_error!("Failed to submit app for review.")
        end
      end

      def self.prepare_test_config(params)
        # Calculate test start time (1 hour from now if not provided)
        start_time = if params[:test_start_time]
                      Time.parse(params[:test_start_time])
                    else
                      Time.now + (60 * 60) # 1 hour from now
                    end

        # Calculate test end time (80 days from start if not provided)
        end_time = if params[:test_end_time]
                    Time.parse(params[:test_end_time])
                  else
                    start_time + (80 * 24 * 60 * 60) # 80 days from start
                  end

        {
          testStartTime: start_time.strftime('%Y-%m-%dT%H:%M:%S+0000'),
          testEndTime: end_time.strftime('%Y-%m-%dT%H:%M:%S+0000'),
          skipManualReview: params[:skip_manual_review] != false,
          feedbackEmail: params[:feedback_email],
          releaseType: 1, # Force open testing release type
          testPhase: true, # Explicitly set test phase
          testMode: 1 # Set test mode to open testing
        }
      end

      def self.update_app_localization_info(token, params)
        metadata_path = if !params[:metadata_path].nil?
                          params[:metadata_path]
                        else
                          'fastlane/metadata/huawei'
                        end

        UI.important("Uploading app localization information from path: #{metadata_path}")

        # gather info from metadata folders
        Dir.glob("#{metadata_path}/*") do |folder|
          uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-language-info?appId=#{params[:app_id]}")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Put.new(uri.request_uri)
          request['client_id'] = params[:client_id]
          request['Authorization'] = "Bearer #{token}"
          request['Content-Type'] = 'application/json'
          lang = File.basename(folder)
          body = { "lang": lang }

          Dir.glob("#{folder}/*") do |file|
            case file
            when /app_name/
              body[:appName] = File.read(file)
            when /app_description/
              body[:appDesc] = File.read(file)
            when /introduction/
              body[:briefInfo] = File.read(file)
            when /release_notes/
              body[:newFeatures] = File.read(file)
            end
          end

          body.length.zero? && next
          UI.important(body.to_json)
          request.body = body.to_json
          response = http.request(request)

          UI.important(response)

          unless response.is_a? Net::HTTPSuccess
            UI.user_error!("Cannot upload localization info (status code: #{response.code}, body: #{response.body})")
            return false
          end

          result_json = JSON.parse(response.body)

          if result_json['ret']['code'].zero?
            UI.success("Successfully uploaded app localization info for #{File.basename(folder)}")
          else
            UI.user_error!(result_json)
          end
        end
      end

      def self.set_gms_dependency(token, client_id, app_id, gms_dependency)
        UI.message("Setting GMS Dependency")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/properties/gms?appId=#{app_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Put.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"

        request.body = {needGms: gms_dependency}.to_json

        response = http.request(request)
        if !response.kind_of? Net::HTTPSuccess
          UI.user_error!("Cannot update gms dependency, please check API Token / Permissions (status code: #{response.code})")
          return false
        end
        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
          UI.success("Successfully updated GMS Dependency")
        else
          UI.user_error!(result_json)
          UI.user_error!("Failed to update GMS Dependency")
        end
      end

    end
  end
end
