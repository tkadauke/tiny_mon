require 'spec_helper'

describe ClickButtonStep do
  describe "#valid?" do
    it "is false by default" do
      expect(ClickButtonStep.new).to be_invalid
    end

    it "is true with name prensent" do
      expect(ClickButtonStep.new(:name => 'button')).to be_valid
    end
  end

  describe "#run!" do
    before { @session = Session.new('/') }

    context "given a scope" do
      before { expect(@session).to receive(:within) }

      it "clicks button" do
        ClickButtonStep.new(:name => 'button', :scope => '.some_div').run!(@session, double)
      end
    end

    context "given no scope" do
      before { expect(@session).to receive(:click_button) }

      it "clicks button" do
        ClickButtonStep.new(:name => 'button').run!(@session, double)
      end
    end
  end
end
