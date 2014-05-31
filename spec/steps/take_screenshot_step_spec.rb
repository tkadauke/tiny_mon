require 'spec_helper'

describe TakeScreenshotStep do
  describe "#run!" do
    let(:check_run) { create(:check_run) }

    before do
      @session = Session.new('/')
      expect(@session).to receive(:take_screenshot).and_return(build(:screenshot))
    end

    it "takes screenshot" do
      TakeScreenshotStep.new.run!(@session, check_run)
    end

    it "creates screenshot record" do
      expect { TakeScreenshotStep.new.run!(@session, check_run) }.to change { Screenshot.count }
    end
  end
end
