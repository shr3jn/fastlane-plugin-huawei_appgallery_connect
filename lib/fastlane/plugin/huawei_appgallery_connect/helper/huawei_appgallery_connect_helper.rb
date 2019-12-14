require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class HuaweiAppgalleryConnectHelper
      def self.get_token(client_id, client_secret)
        UI.message("Fetching app access token")

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

        result_json = JSON.parse(res.body)

        UI.message(response.body)
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

        result_json = JSON.parse(response.body)

        if result_json['uploadUrl'].nil?
          UI.message('Cannot obtain upload url')
          return false
        else
          UI.message('Uploading app')
          # Upload App
          boundary = "755754302457647"
          uri = URI(result_json['uploadUrl'])
          # uri = URI("http://localhost/dashboard/test")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          request = Net::HTTP::Post.new(uri)
          request['Content-Type'] = "multipart/form-data, boundary=#{boundary}"

          post_body = []
          # add the auth code
          post_body << "--#{boundary}\r\n"
          post_body << "Content-Disposition: form-data; name=\"authCode\"\r\n\r\n"
          post_body << result_json['authCode']
          # add the file count
          post_body << "\r\n--#{boundary}\r\n"
          post_body << "Content-Disposition: form-data; name=\"fileCount\"\r\n\r\n"
          post_body << "1"
          # add the apk
          post_body << "\r\n--#{boundary}\r\n"
          post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"release.apk\"\r\n"
          post_body << "Content-Type: multipart/form-data\r\n\r\n"
          post_body << File.read(apk_path).encode('utf-8')
          post_body << "\r\n--#{boundary}--\r\n"
          request.body = post_body.join

          result = http.request(request)
          result_json = JSON.parse(result.body)

          if result_json['result']['result_code'].to_i == 0
            UI.message('Upload app to AppGallery Connect successful')
            UI.message("Saving app information")

            uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-file-info?appId=#{app_id}")

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Put.new(uri.request_uri)
            request["client_id"] = client_id
            request["Authorization"] = "Bearer #{token}"

            data = {fileType: 5, lang: 'en-GB', files: [{

                fileName: "release.apk",
                fileDestUrl: result_json['result']['UploadFileRsp']['fileInfoList'][0]['fileDestUlr'],
                size: result_json['result']['UploadFileRsp']['fileInfoList'][0]['size'].to_s

            }] }.to_json

            request.body = data
            response = http.request(request)

            result_json = JSON.parse(response.body)

            if result_json['ret']['code'] == 0
              UI.message("App information saved.")
              return true
            else
              UI.message("Failed to save app information")
              return false
            end
          else
            return false
          end
        end
      end

      def self.submit_app_for_review(token, client_id, app_id)
        UI.message("Submitting app for review")

        uri = URI.parse("https://connect-api.cloud.huawei.com/api/publish/v2/app-submit?appId=#{app_id}")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["client_id"] = client_id
        request["Authorization"] = "Bearer #{token}"
        response = http.request(request)

        result_json = JSON.parse(response.body)

        if result_json['ret']['code'] == 0
            UI.message("Successfully submitted app for review")
        else
          UI.message("Failed to submit app for review")
        end

      end
    end
  end
end
