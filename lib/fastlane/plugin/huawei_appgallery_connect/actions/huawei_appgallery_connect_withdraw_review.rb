require 'fastlane/action'
require_relative '../helper/huawei_appgallery_connect_helper'

module Fastlane
  module Actions
    class HuaweiAppgalleryConnectWithdrawReviewAction < Action
      def self.run(params)
        token = Helper::HuaweiAppgalleryConnectHelper.get_token(params[:client_id], params[:client_secret])

        if token.nil?
          UI.user_error!("Cannot retrieve token, please check your client ID and client secret")
        end

        Helper::HuaweiAppgalleryConnectHelper.withdraw_app_review(token, params[:client_id], params[:app_id])
      end

      def self.description
        "Withdraw an app version currently under AppGallery review"
      end

      def self.authors
        ["Shreejan Shrestha"]
      end

      def self.return_value
        "Returns true when AppGallery accepts the review withdrawal"
      end

      def self.details
        "Withdraws an app version from review so it can be updated and submitted again"
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
                                       type: String)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
