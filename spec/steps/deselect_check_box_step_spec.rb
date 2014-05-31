require 'spec_helper'

describe DeselectCheckBoxStep do
  describe "#valid?" do
    it "is false by default" do
      expect(DeselectCheckBoxStep.new).to be_invalid
    end

    it "is true with name prensent" do
      expect(DeselectCheckBoxStep.new(:name => 'checkbox')).to be_valid
    end
  end

  describe "#run!" do
    before { @session = Session.new('/') }

    context "given a scope" do
      before { expect(@session).to receive(:within) }

      it "deselects checkbox" do
        DeselectCheckBoxStep.new(:name => 'checkbox', :scope => '.some_div').run!(@session, double)
      end
    end

    context "given no scope" do
      before { expect(@session).to receive(:uncheck) }

      it "deselects checkbox" do
        DeselectCheckBoxStep.new(:name => 'checkbox').run!(@session, double)
      end
    end
  end
end
