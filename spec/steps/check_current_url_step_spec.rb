require 'spec_helper'

describe CheckCurrentUrlStep do
  describe "#valid?" do
    it "is false by default" do
      expect(CheckCurrentUrlStep.new).to be_invalid
    end

    it "is true with content prensent" do
      expect(CheckCurrentUrlStep.new(:url => 'http://www.google.com')).to be_valid
    end
  end

  describe "#run!" do
    before do
      @session = Session.new('/')
      allow(@session.driver).to receive(:current_url).and_return('http://www.example.com/some?url')
    end

    it "logs" do
      step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/some?url')
      expect { step.run!(@session, double) }.to change { @session.log_entries.size }.by(1)
    end

    context "given content is present" do
      context "in regular mode" do
        it "raises nothing" do
          step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/some?url')
          expect { step.run!(@session, double) }.not_to raise_error
        end
      end

      context "in negate mode" do
        it "raises error" do
          step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/some?url', :negate => true)
          expect { step.run!(@session, double) }.to raise_error(CheckCurrentUrlStep::UrlCheckFailed)
        end
      end
    end

    context "given content is not present" do
      context "in regular mode" do
        it "raises error" do
          step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/foobar')
          expect { step.run!(@session, double) }.to raise_error(CheckCurrentUrlStep::UrlCheckFailed)
        end
      end

      context "in negate mode" do
        it "raises nothing" do
          step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/foobar', :negate => true)
          expect { step.run!(@session, double) }.not_to raise_error
        end
      end
    end
  end
end
