require 'spec_helper'

describe SubmitFormStep do
  describe "#valid?" do
    it "is false by default" do
      expect(SubmitFormStep.new).to be_invalid
    end

    it "is true with name prensent" do
      expect(SubmitFormStep.new(:name => 'form')).to be_valid
    end
  end

  describe "#run!" do
    before do
      @session = Session.new('/')
      expect(@session).to receive(:submit_form)
    end

    it "logs" do
      step = SubmitFormStep.new(:name => 'form')
      expect { step.run!(@session, double) }.to change { @session.log_entries.size }.by(1)
    end

    it "submits form" do
      SubmitFormStep.new(:name => 'form').run!(@session, double)
    end
  end
end
