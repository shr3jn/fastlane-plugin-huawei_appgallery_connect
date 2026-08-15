require 'spec_helper'

describe Fastlane::Helper::HuaweiAppgalleryConnectHelper do
  describe '.submit_app_for_review' do
    let(:params) do
      {
        app_id: 'app-id',
        client_id: 'client-id',
        changelog_path: '/tmp/changelog'
      }
    end

    [9, 301].each do |length|
      it "rejects a #{length}-character changelog before calling Huawei" do
        allow(File).to receive(:read).with('/tmp/changelog').and_return('a' * length)
        expect(Net::HTTP).not_to(receive(:new))
        expect(Fastlane::UI).to receive(:user_error!).with(
          "Failed to submit app for review. Changelog must be between 10 and 300 characters (got #{length})"
        )

        described_class.submit_app_for_review('token', params)
      end
    end

    [10, 300].each do |length|
      it "accepts a #{length}-character changelog" do
        allow(File).to receive(:read).with('/tmp/changelog').and_return('a' * length)

        response = Net::HTTPOK.new('1.1', '200', 'OK')
        allow(response).to receive(:body).and_return('{"ret":{"code":0}}')

        http = instance_double(Net::HTTP)
        allow(http).to receive(:use_ssl=).with(true)
        expect(Net::HTTP).to receive(:new).with('connect-api.cloud.huawei.com', 443).and_return(http)
        expect(http).to receive(:request) do |request|
          expect(request.path).to include("remark=#{'a' * length}")
        end.and_return(response)
        expect(Fastlane::UI).to receive(:success).with('Successfully submitted app for review')

        described_class.submit_app_for_review('token', params)
      end
    end
  end
end
