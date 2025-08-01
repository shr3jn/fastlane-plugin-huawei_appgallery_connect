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

          FastlaneCore::ConfigItem.new(key: :privacy_policy_url,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PRIVACY_POLICY",
                                       description: "Privacy Policy URL",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :changelog_path,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_CHANGELOG_PATH",
                                       description: "Path to Changelog file (Default empty)",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :phase_wise_release,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_WISE_RELEASE",
                                       description: "Phase wise release",
                                       optional: true,
                                       conflicting_options: [:release_time],
                                       type: Boolean),

          FastlaneCore::ConfigItem.new(key: :phase_release_start_time,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_RELEASE_START_TIME",
                                       description: "Phase release start time in UTC format (yyyy-MM-dd'T'HH:mm:ssZZ)",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :phase_release_end_time,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_RELEASE_END_TIME",
                                       description: "Phase release end time in UTC format (yyyy-MM-dd'T'HH:mm:ssZZ)",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :phase_release_percent,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_RELEASE_PERCENT",
                                       description: "Percentage of phase release (0-100)",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :phase_release_description,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_PHASE_RELEASE_DESCRIPTION",
                                       description: "Phase release description",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :release_time,
                                       env_name: "HUAWEI_APPGALLERY_CONNECT_RELEASE_TIME",
                                       description: "Release time in UTC format for app release on a specific date (yyyy-MM-dd'T'HH:mm:ssZZ)",
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
                                     description: "App Package IDs separated by commas",
                                     optional: true,
                                     type: String),

          # Open Testing Configuration
          FastlaneCore::ConfigItem.new(key: :use_testing_version,
                                     env_name: "HUAWEI_APPGALLERY_USE_TESTING_VERSION",
                                     description: "Enable open testing for the app",
                                     optional: true,
                                     default_value: false,
                                     type: Boolean),

          FastlaneCore::ConfigItem.new(key: :skip_manual_review,
                                     env_name: "HUAWEI_APPGALLERY_SKIP_MANUAL_REVIEW",
                                     description: "Skip manual review for internal testing",
                                     optional: true,
                                     default_value: true,
                                     type: Boolean),

          FastlaneCore::ConfigItem.new(key: :test_start_time,
                                     env_name: "HUAWEI_APPGALLERY_TEST_START_TIME",
                                     description: "Test start time in UTC format (yyyy-MM-dd'T'HH:mm:ssZZ). If not provided, defaults to 1 hour from now",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :test_end_time,
                                     env_name: "HUAWEI_APPGALLERY_TEST_END_TIME",
                                     description: "Test end time in UTC format (yyyy-MM-dd'T'HH:mm:ssZZ). If not provided, defaults to 80 days from start time",
                                     optional: true,
                                     type: String),

          FastlaneCore::ConfigItem.new(key: :feedback_email,
                                     env_name: "HUAWEI_APPGALLERY_FEEDBACK_EMAIL",
                                     description: "Email address for test feedback",
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
