describe Fastlane::Actions::HuaweiAppgalleryConnectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The huawei_appgallery_connect plugin is working!")

      Fastlane::Actions::HuaweiAppgalleryConnectAction.run(nil)
    end
  end
end
