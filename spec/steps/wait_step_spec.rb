require 'spec_helper'

describe WaitStep do
  describe "#run!" do
    before { @session = Session.new('/') }

    it "sleeps" do
      step = WaitStep.new(:duration => 10)
      expect(step).to receive(:sleep).with(10)
      step.run!(@session, double)
    end
  end
end
