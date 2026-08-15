require 'fastlane/action'
require_relative '../helper/huawei_appgallery_connect_helper'

module Fastlane
  module Actions
    class HuaweiAppgalleryConnectUploadAssetsAction < Action
      def self.run(params)
        token = Helper::HuaweiAppgalleryConnectHelper.get_token(params[:client_id], params[:client_secret])
        UI.user_error!('Cannot retrieve Huawei AppGallery Connect token') if token.nil?

        paths = Array(params[:asset_paths]).flat_map { |path| File.directory?(path) ? Dir[File.join(path, '*')] : path }
        UI.user_error!('Provide at least one asset path') if paths.empty?
        paths.each do |path|
          Helper::HuaweiAppgalleryConnectHelper.upload_asset(
            token, params[:client_id], params[:app_id], path,
            file_type: params[:file_type], lang: params[:lang]
          )
        end
        UI.success("Uploaded #{paths.length} AppGallery asset(s)")
      end

      def self.description
        'Upload app icons, screenshots, and other visual assets to Huawei AppGallery Connect'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :client_id, env_name: 'HUAWEI_APPGALLERY_CONNECT_CLIENT_ID', description: 'Huawei AppGallery Connect Client ID', optional: false, type: String),
          FastlaneCore::ConfigItem.new(key: :client_secret, env_name: 'HUAWEI_APPGALLERY_CONNECT_CLIENT_SECRET', description: 'Huawei AppGallery Connect Client Secret', optional: false, type: String),
          FastlaneCore::ConfigItem.new(key: :app_id, env_name: 'HUAWEI_APPGALLERY_CONNECT_APP_ID', description: 'Huawei AppGallery Connect App ID', optional: false, type: String),
          FastlaneCore::ConfigItem.new(key: :asset_paths, env_name: 'HUAWEI_APPGALLERY_ASSET_PATHS', description: 'Asset file paths or directories', optional: false, type: Array),
          FastlaneCore::ConfigItem.new(key: :file_type, env_name: 'HUAWEI_APPGALLERY_ASSET_FILE_TYPE', description: 'Huawei Publishing API fileType (default: 5)', optional: true, default_value: 5, type: Integer),
          FastlaneCore::ConfigItem.new(key: :lang, env_name: 'HUAWEI_APPGALLERY_ASSET_LANGUAGE', description: 'Language tag for localized assets, for example en-US', optional: true, type: String)
        ]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
