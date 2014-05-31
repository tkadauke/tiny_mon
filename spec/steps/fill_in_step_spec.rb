require 'spec_helper'

describe FillInStep do
  describe "#valid?" do
    it "is false by default" do
      expect(FillInStep.new).to be_invalid
    end

    it "is true with field and value prensent" do
      expect(FillInStep.new(:field => 'login', :value => 'username')).to be_valid
    end
  end

  describe "#run!" do
    before do
      @session = Session.new('/')
      expect(@session).to receive(:fill_in)
    end

    it "fills in field" do
      FillInStep.new(:field => 'login', :value => 'username').run!(@session, double)
    end
  end
end
