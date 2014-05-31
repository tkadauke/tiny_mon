require 'spec_helper'

describe RunScriptStep do
  describe "#run!" do
    before do
      @session = Session.new('/')
      expect(@session).to receive(:execute_script)
    end

    it "fills in field" do
      RunScriptStep.new(:code => "alert('hello')").run!(@session, double)
    end
  end
end
