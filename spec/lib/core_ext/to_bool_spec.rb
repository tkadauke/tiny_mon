require 'spec_helper'

describe Object do
  describe "#to_bool" do
    it "is true" do
      expect(Object.new.to_bool).to be_true
    end
  end
end

describe NilClass do
  describe "#to_bool" do
    it "is false" do
      expect(nil.to_bool).to be_false
    end
  end
end

describe FalseClass do
  describe "#to_bool" do
    it "is false" do
      expect(false.to_bool).to be_false
    end
  end
end

describe TrueClass do
  describe "#to_bool" do
    it "is false" do
      expect(true.to_bool).to be_true
    end
  end
end

describe Numeric do
  describe "#to_bool" do
    it "is false for 0" do
      expect(0.to_bool).to be_false
    end

    it "is false for 0.0" do
      expect(0.0.to_bool).to be_false
    end

    it "is true for other Fixnums" do
      expect(1.to_bool).to be_true
    end

    it "is true for other Floats" do
      expect(17.5.to_bool).to be_true
    end
  end
end

describe String do
  describe "#to_bool" do
    it "is true for '1'" do
      expect('1'.to_bool).to be_true
    end

    it "is true for 'true'" do
      expect('true'.to_bool).to be_true
    end

    it "is true for 'TRUE'" do
      expect('TRUE'.to_bool).to be_true
    end

    it "is false for '0'" do
      expect('0'.to_bool).to be_false
    end

    it "is false for 'false'" do
      expect('false'.to_bool).to be_false
    end

    it "is false for other strings" do
      expect('foobar'.to_bool).to be_false
    end
  end
end
