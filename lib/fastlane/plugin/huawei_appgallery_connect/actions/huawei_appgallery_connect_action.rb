require 'fastlane/action'
require_relative '../helper/huawei_appgallery_connect_helper'

module Fastlane
  module Actions
    class HuaweiAppgalleryConnectAction < Action
      def self.run(params)
        token = Helper::HuaweiAppgalleryConnectHelper.get_token(params[:client_id], params[:client_secret])

        if token.nil?
          UI.message("Cannot retrieve token, please check your client ID and client secret")
        else
          upload_app = Helper::HuaweiAppgalleryConnectHelper.upload_app(token, params[:client_id], params[:app_id], params[:apk_path])

          if upload_app
            Helper::HuaweiAppgalleryConnectHelper.submit_app_for_review(token, params[:client_id], params[:app_id])
          end
        end
        # Helper::HuaweiAppgalleryConnectHelper.getAppInfo(token, params[:client_id], params[:app_id])
      end

      def self.description
        "Huawei AppGallery Connect Plugin"
      end

      def self.authors
        ["Shreejan Shrestha"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Fastlane plugin to upload Android app to Huawei AppGallery Connect"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :client_id,
                                  env_name: "HUAWEI_APPGALLERY_CONNECT_CLIENT_ID",
                               description: "Huawei AppGallery Connect Client ID",
                                  optional: false,
                                      type: String),

          FastlaneCore::ConfigItem.new(key: :client_secret,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_CLIENT_SECRET",
                                     description: "Huawei AppGallery Connect Client Secret",
                                     optional: false,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_APP_ID",
                                       description: "Huawei AppGallery Connect App ID",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :apk_path,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_APK_PATH",
                                       description: "Path to APK file for upload",
                                       optional: false,
                                       type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
        true
      end
    end
  end
end
