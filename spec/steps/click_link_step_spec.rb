require 'spec_helper'

describe ClickLinkStep do
  describe "#valid?" do
    it "is false by default" do
      expect(ClickLinkStep.new).to be_invalid
    end

    it "is true with name prensent" do
      expect(ClickLinkStep.new(:name => 'link')).to be_valid
    end
  end

  describe "#run!" do
    before { @session = Session.new('/') }

    context "given a scope" do
      before { expect(@session).to receive(:within) }

      it "clicks link" do
        ClickLinkStep.new(:name => 'link', :scope => '.some_div').run!(@session, double)
      end
    end

    context "given no scope" do
      before { expect(@session).to receive(:click_link) }

      it "clicks link" do
        ClickLinkStep.new(:name => 'link').run!(@session, double)
      end
    end
  end
end
