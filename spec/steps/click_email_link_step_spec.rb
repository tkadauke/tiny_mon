require 'spec_helper'

describe ClickEmailLinkStep do
  describe "#valid?" do
    it "is false by default" do
      expect(ClickEmailLinkStep.new).to be_invalid
    end

    it "is true with link_pattern prensent" do
      expect(ClickEmailLinkStep.new(:link_pattern => 'http://google.com')).to be_valid
    end
  end

  describe "#run!" do
    before { @session = Session.new('/') }

    context "given no scope" do
      before { expect(@session).to receive(:click_email_link) }

      it "clicks link in email" do
        ClickEmailLinkStep.new(:link_pattern => 'http://google.com').run!(@session, double)
      end
    end
  end
end
