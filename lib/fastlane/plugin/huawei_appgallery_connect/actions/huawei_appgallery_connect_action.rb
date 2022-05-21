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

          upload_app = Helper::HuaweiAppgalleryConnectHelper.upload_app(token, params[:client_id], params[:app_id], params[:apk_path], params[:is_aab])
          if params[:delay_before_submit_for_review] == nil
              UI.message("Waiting 10 seconds for upload to get processed...")
              sleep(10)
          else
             UI.message("Waiting #{params[:delay_before_submit_for_review]} seconds for upload to get processed...")
             sleep(params[:delay_before_submit_for_review])
          end
          self.submit_for_review(token, upload_app, params)

        end
        # Helper::HuaweiAppgalleryConnectHelper.getAppInfo(token, params[:client_id], params[:app_id])
      end

      def self.submit_for_review(token, upload_app, params)
        if params[:is_aab] && upload_app["success"] == true && params[:submit_for_review] != false
          compilationStatus = Helper::HuaweiAppgalleryConnectHelper.query_aab_compilation_status(token, params, upload_app["pkgVersion"])
          if compilationStatus == 1
            UI.important("aab file is currently processing, waiting for 2 minutes...")
            sleep(120)
            self.submit_for_review(token, upload_app, params)
          elsif compilationStatus == 2
            Helper::HuaweiAppgalleryConnectHelper.submit_app_for_review(token, params)
          else
            UI.user_error!("Compilation of aab failed")
          end
        elsif upload_app["success"] == true && params[:submit_for_review] != false
          Helper::HuaweiAppgalleryConnectHelper.submit_app_for_review(token, params)
        end
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

          FastlaneCore::ConfigItem.new(key: :is_aab,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_IS_AAB",
                                       description: "Specify this to be true if you're uploading aab instead of apk",
                                       optional: true,
                                       type: Boolean),

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
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :submit_for_review,
                                     env_name: "HUAWEI_APPGALLERY_SUBMIT_FOR_REVIEW",
                                     description: "Should submit the app for review. The default value is true. If set false will only upload the app, and you can submit for review from the console",
                                     optional: true,
                                     type: Boolean),

          FastlaneCore::ConfigItem.new(key: :delay_before_submit_for_review,
                                       env_name: "HUAWEI_APPGALLERY_DELAY_BEFORE_REVIEW",
                                       description: "Delay before submitting the app for review. Default is 10 seconds. Change this to a higher value if you are having issues submitting the app for review",
                                       optional: true,
                                       type: Integer),

           FastlaneCore::ConfigItem.new(key: :package_ids,
                                                  env_name: "HUAWEI_APPGALLERY_PACKAGE_IDS",
                                                  description: "App Package IDs separated by commas.",
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
