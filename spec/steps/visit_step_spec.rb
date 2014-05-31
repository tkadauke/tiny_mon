require 'spec_helper'

describe VisitStep do
  describe "#valid?" do
    it "is false by default" do
      expect(VisitStep.new).to be_invalid
    end

    it "is true with url prensent" do
      expect(VisitStep.new(:url => '/')).to be_valid
    end
  end

  describe "#run!" do
    before do
      @session = Session.new('/')
      expect(@session).to receive(:visit)
    end

    it "visits url" do
      VisitStep.new(:url => '/').run!(@session, double)
    end
  end
end
