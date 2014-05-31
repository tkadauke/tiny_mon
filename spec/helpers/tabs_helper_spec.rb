require 'spec_helper'

describe TabsHelper do
  describe "#tabs" do
    it "contains tab link text" do
      result = helper.tabs { |b| b.tab :first, 'acme', 'buzz' }
      expect(result).to match(/acme/)
    end

    it "contains tab link url" do
      result = helper.tabs { |b| b.tab :first, 'acme', 'buzz' }
      expect(result).to match(/buzz/)
    end

    it "allows more than one tab" do
      result = helper.tabs { |b| b.tab :first, 'foo', 'bar'; b.tab :second, 'beep', 'boop' }
      expect(result).to match(/beep/)
    end

    it "has no selected tab by default" do
      result = helper.tabs { |b| b.tab :first, 'acme', 'buzz' }
      expect(result).not_to match(/active/)
    end

    it "marks specified selected tab" do
      result = helper.tabs(:selected => :first) { |b| b.tab :first, 'acme', 'buzz' }
      expect(result).to match(/active/)
    end
  end
end
