require 'spec_helper'

describe ChooseRadioButtonStep do
  describe "#valid?" do
    it "is false by default" do
      expect(ChooseRadioButtonStep.new).to be_invalid
    end

    it "is true with name prensent" do
      expect(ChooseRadioButtonStep.new(:name => 'radio_button')).to be_valid
    end
  end

  describe "#run!" do
    before { @session = Session.new('/') }

    context "given a scope" do
      before { expect(@session).to receive(:within) }

      it "chooses radio button" do
        ChooseRadioButtonStep.new(:name => 'radio_button', :scope => '.some_div').run!(@session, double)
      end
    end

    context "given no scope" do
      before { expect(@session).to receive(:choose) }

      it "chooses radio button" do
        ChooseRadioButtonStep.new(:name => 'radio_button').run!(@session, double)
      end
    end
  end
end
