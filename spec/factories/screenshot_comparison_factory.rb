FactoryGirl.define do
  factory :screenshot_comparison do
    checksum do
      FileUtils.cp "#{Rails.root}/spec/fixtures/empty.png", "#{Rails.root}/spec/fixtures/test_candidate.png"
      ScreenshotFile.store!("#{Rails.root}/spec/fixtures/test_candidate.png", :thumbnail => true).checksum
    end
  end
end
