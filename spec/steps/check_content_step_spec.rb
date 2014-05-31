require 'spec_helper'

describe CheckContentStep do
  describe "#valid?" do
    it "is false by default" do
      expect(CheckContentStep.new).to be_invalid
    end

    it "is true with content prensent" do
      expect(CheckContentStep.new(:content => 'hello')).to be_valid
    end
  end

  describe "#run!" do
    before do
      @session = Session.new('/')
      allow(@session.driver).to receive(:body).and_return('something with interesting content')
    end

    it "logs" do
      step = CheckContentStep.new(:content => 'interesting')
      expect { step.run!(@session, double) }.to change { @session.log_entries.size }.by(1)
    end

    context "given content is present" do
      context "in regular mode" do
        it "raises nothing" do
          step = CheckContentStep.new(:content => 'interesting')
          expect { step.run!(@session, double) }.not_to raise_error
        end
      end

      context "in negate mode" do
        it "raises error" do
          step = CheckContentStep.new(:content => 'interesting', :negate => true)
          expect { step.run!(@session, double) }.to raise_error(CheckContentStep::ContentCheckFailed)
        end
      end
    end

    context "given content is not present" do
      context "in regular mode" do
        it "raises error" do
          step = CheckContentStep.new(:content => 'not present')
          expect { step.run!(@session, double) }.to raise_error(CheckContentStep::ContentCheckFailed)
        end
      end

      context "in negate mode" do
        it "raises nothing" do
          step = CheckContentStep.new(:content => 'not present', :negate => true)
          expect { step.run!(@session, double) }.not_to raise_error
        end
      end
    end
  end
end