require_relative 'spec_helper'

describe Fastlane::Actions::HuaweiAppgalleryConnectUploadAssetsAction do
  it 'declares asset paths and language options' do
    keys = described_class.available_options.map(&:key)
    expect(keys).to include(:asset_paths, :file_type, :lang)
    expect(described_class.description).to include('visual assets')
  end

  it 'expands asset directories before uploading' do
    allow(Fastlane::Helper::HuaweiAppgalleryConnectHelper).to receive(:get_token).and_return('token')
    allow(Fastlane::Helper::HuaweiAppgalleryConnectHelper).to receive(:upload_asset)
    allow(File).to receive(:directory?).with('/tmp/assets').and_return(true)
    allow(Dir).to receive(:[]).with('/tmp/assets/*').and_return(['/tmp/assets/icon.png', '/tmp/assets/shot.png'])

    described_class.run(client_id: 'id', client_secret: 'secret', app_id: 'app', asset_paths: ['/tmp/assets'], file_type: 5, lang: 'en-US')

    expect(Fastlane::Helper::HuaweiAppgalleryConnectHelper).to have_received(:upload_asset).twice
  end
end
