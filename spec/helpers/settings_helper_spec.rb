require 'spec_helper'

describe SettingsHelper do
  describe "#translate_if_possible" do
    context "given a hash parameter" do
      let(:hash) { { "en" => "hello" } }

      it "picks out string for the current locale" do
        I18n.locale = :en
        result = helper.translate_if_possible(hash)
        expect(result).to eq("hello")
      end

      it "returns nothing if there is no string for the current locale" do
        I18n.locale = :de
        result = helper.translate_if_possible(hash)
        expect(result).to be_nil
      end
    end

    context "given a string parameter" do
      it "returns string" do
        result = helper.translate_if_possible("world")
        expect(result).to eq("world")
      end
    end
  end
end
