require 'fastlane/action'
require_relative '../helper/huawei_appgallery_connect_helper'

module Fastlane
  module Actions
    module SharedValues
      ANDROID_APPGALLERY_APP_ID = :ANDROID_APPGALLERY_APP_ID
    end
    class HuaweiAppgalleryConnectGetAppIdAction < Action

      def self.run(params)
        token = Helper::HuaweiAppgalleryConnectHelper.get_token(params[:client_id], params[:client_secret])

        if token.nil?
          UI.message("Cannot retrieve token, please check your client ID and client secret")
        else 
          appID = Helper::HuaweiAppgalleryConnectHelper.get_app_id(token, params[:client_id],params[:package_id])
          Actions.lane_context[SharedValues::ANDROID_APPGALLERY_APP_ID] = appID
          return appID
        end
      end

      def self.description
        "Huawei AppGallery Connect Plugin"
      end

      def self.authors
        ["Shreejan Shrestha", "Kirill Mandrygin"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Fastlane plugin to get Android app to Huawei AppGallery Connect information"
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

          FastlaneCore::ConfigItem.new(key: :package_id,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PACKAGE_ID",
                                       description: "Huawei AppGallery Connect Package ID",
                                       optional: false,
                                       type: String),

        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
        true
      end

      def self.example_code
        [
          'app_id = huawei_appgallery_connect_get_app_id'
        ]
      end

    end
  end
end
