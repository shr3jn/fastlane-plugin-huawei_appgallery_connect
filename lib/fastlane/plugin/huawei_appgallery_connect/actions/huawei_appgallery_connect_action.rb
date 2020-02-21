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

          if params[:privacy_policy_url] != nil
            Helper::HuaweiAppgalleryConnectHelper.update_appinfo(params[:client_id], token, params[:app_id], params[:privacy_policy_url])
          end

          apk_lang = params[:apk_lang] == nil ? 'en-GB' : params[:apk_lang]

          upload_app = Helper::HuaweiAppgalleryConnectHelper.upload_app(token, params[:client_id], params[:app_id], params[:apk_path], apk_lang)

          if upload_app
            Helper::HuaweiAppgalleryConnectHelper.submit_app_for_review(token, params)
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
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :changelog_path,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_CHANGELOG_PATH",
                                     description: "Path to Changelog file (Default empty)",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :privacy_policy_url,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_PRIVACY",
                                     description: "Privacy Policy URL",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :phase_wise_release,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_WISE_RELEASE",
                                     description: "Phase wise release",
                                     optional: true,
                                     conflicting_options: [:release_time],
                                     type: Boolean),

          FastlaneCore::ConfigItem.new(key: :phase_release_start_time,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_WISE_RELEASE_START_TIME",
                                     description: "Start time of the validity period of the release by phase. The value is UTC time in the following format: yyyy-MM-dd 'T' HH:mm:ssZZ",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :phase_release_end_time,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_WISE_RELEASE_END_TIME",
                                     description: "End time of the validity period of the release by phase. The value is UTC time in the following format: yyyy-MM-dd 'T' HH:mm:ssZZ",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :phase_release_percent,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_WISE_RELEASE_PERCENT",
                                     description: "Percentage of the release by phase. The value must be accurate to two decimal places and does not contain the percent sign (%)",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :phase_release_description,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_WISE_RELEASE_DESCRIPTION",
                                     description: "Phase-based release description. (Max 500 characters)",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :release_time,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_RELEASE_TIME",
                                       description: "Release time in UTC format for app release on a specific date. The format is yyyy-MM-dd'T'HH:mm:ssZZ)",
                                       optional: true,
                                       conflicting_options: [:phase_wise_release],
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :apk_lang,
                                     env_name: "HUAWEI_APPGALLERY_CONNECT_APK_LANGUAGE",
                                     description: "Language type. For details, please refer to https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agcapi-reference-langtype",
                                     optional: true,
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
