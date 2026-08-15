require 'spec_helper'

describe Fastlane::Actions::HuaweiAppgalleryConnectWithdrawReviewAction do
  let(:helper) { Fastlane::Helper::HuaweiAppgalleryConnectHelper }
  let(:params) do
    {
      client_id: 'client-id',
      client_secret: 'client-secret',
      app_id: 'app-id'
    }
  end

  describe '.run' do
    it 'authenticates and withdraws the app review' do
      expect(helper).to receive(:get_token).with('client-id', 'client-secret').and_return('token')
      expect(helper).to receive(:withdraw_app_review).with('token', 'client-id', 'app-id').and_return(true)

      expect(described_class.run(params)).to be(true)
    end
  end

  describe '.is_supported?' do
    it 'supports Android only' do
      expect(described_class.is_supported?(:android)).to be(true)
      expect(described_class.is_supported?(:ios)).to be(false)
    end
  end
end

describe Fastlane::Helper::HuaweiAppgalleryConnectHelper do
  describe '.withdraw_app_review' do
    it 'posts the app ID to the AppGallery withdrawal endpoint' do
      response = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(response).to receive(:body).and_return('{"ret":{"code":0}}')

      http = instance_double(Net::HTTP)
      allow(http).to receive(:use_ssl=).with(true)
      expect(Net::HTTP).to receive(:new).with('connect-api.cloud.huawei.com', 443).and_return(http)
      expect(http).to receive(:request) do |request|
        expect(request).to be_a(Net::HTTP::Post)
        expect(request.path).to eq('/api/publish/v1/app-info/withdraw?appId=app-id')
        expect(request['client_id']).to eq('client-id')
        expect(request['Authorization']).to eq('Bearer token')
        expect(request['Content-Type']).to eq('application/json')
      end.and_return(response)
      expect(Fastlane::UI).to receive(:success).with('Successfully withdrew app review')

      expect(described_class.withdraw_app_review('token', 'client-id', 'app-id')).to be(true)
    end
  end
end
