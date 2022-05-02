require 'fastlane/action'
require_relative '../helper/huawei_appgallery_connect_helper'

module Fastlane
  module Actions
    class HuaweiAppgalleryConnectUpdateAppLocalizationAction < Action
      def self.run(params)
        token = Helper::HuaweiAppgalleryConnectHelper.get_token(params[:client_id], params[:client_secret])

        if token.nil?
          UI.message('Cannot retrieve token, please check your client ID and client secret')
        else
          Helper::HuaweiAppgalleryConnectHelper.update_app_localization_info(token, params)
        end
      end

      def self.description
        'Huawei AppGallery Connect Plugin'
      end

      def self.authors
        ['Shreejan Shrestha', 'Nikita Blizniuk']
      end

      def self.return_value; end

      def self.details
        'Fastlane plugin to upload Android app to Huawei AppGallery Connect'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :client_id,
                                       env_name: 'HUAWEI_APPGALLERY_CONNECT_CLIENT_ID',
                                       description: 'Huawei AppGallery Connect Client ID',
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :client_secret,
                                       env_name: 'HUAWEI_APPGALLERY_CONNECT_CLIENT_SECRET',
                                       description: 'Huawei AppGallery Connect Client Secret',
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :app_id,
                                       env_name: 'HUAWEI_APPGALLERY_CONNECT_APP_ID',
                                       description: 'Huawei AppGallery Connect App ID',
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :metadata_path,
                                       env_name: 'HUAWEI_APPGALLERY_CONNECT_METADATA_PATH',
                                       description: 'Huawei Appgallery Connect Metadata Path. Default is fastalane/metadata/huawei',
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
