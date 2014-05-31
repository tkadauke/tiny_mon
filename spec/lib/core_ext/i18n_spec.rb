require 'spec_helper'

describe I18n do
  describe ".with_locale" do
    before { @locale = I18n.locale }

    it "changes the locale inside the block" do
      I18n.with_locale(:de) do
        expect(I18n.locale).not_to eq(@locale)
      end
    end

    it "changes the locale back after the block" do
      I18n.with_locale(:de) {}
      expect(I18n.locale).to eq(@locale)
    end

    it "changes the locale back in case of exception" do
      begin
        I18n.with_locale(:de) do
          raise StandardError
        end
      rescue StandardError
      end
      expect(I18n.locale).to eq(@locale)
    end
  end
end
