require 'spec_helper'

describe Time do
  describe "#seconds_to_now" do
    context "given time is in the past" do
      before { @past = Time.now - 10 }

      it "returns the correct amount" do
        expect(@past.seconds_to_now.round).to eq(10)
      end
    end

    context "given time is in the future" do
      before { @past = Time.now + 10 }

      it "returns the correct amount" do
        expect(@past.seconds_to_now.round).to eq(-10)
      end
    end
  end
end
