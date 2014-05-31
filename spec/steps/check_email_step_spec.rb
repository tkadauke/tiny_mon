require 'spec_helper'

describe CheckEmailStep do
  describe "#valid?" do
    it "is false by default" do
      expect(CheckEmailStep.new).to be_invalid
    end

    it "is true with server, login and password prensent" do
      expect(CheckEmailStep.new(:server => 'mail.gmail.com', :login => 'user@gmail.com', :password => 'foo')).to be_valid
    end
  end

  describe "#run!" do
    before do
      @session = Session.new('/')
      expect(@session).to receive(:check_email)
    end

    it "logs" do
      step = CheckEmailStep.new(:server => 'mail.gmail.com', :login => 'user@gmail.com', :password => 'foo')
      expect { step.run!(@session, double) }.to change { @session.log_entries.size }.by(1)
    end
  end
end
