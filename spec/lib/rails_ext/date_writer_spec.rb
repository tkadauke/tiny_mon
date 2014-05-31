require 'spec_helper'

describe DateWriter do
  class DateWriterTestClass
    extend DateWriter

    def initialize(attributes = {})
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    attr_accessor :date
    date_writer :date
  end

  let(:obj) { DateWriterTestClass.new }

  describe "#date_writer" do
    describe "year setter" do
      it "is defined" do
        obj.send("date(1i)=", 2013)
        expect(obj.date.year).to eq(2013)
      end

      it "accepts string" do
        obj.send("date(1i)=", "2013")
        expect(obj.date.year).to eq(2013)
      end
    end

    describe "month setter" do
      it "is defined" do
        obj.send("date(2i)=", 10)
        expect(obj.date.month).to eq(10)
      end

      it "accepts string" do
        obj.send("date(2i)=", "10")
        expect(obj.date.month).to eq(10)
      end
    end

    describe "day setter" do
      it "is defined" do
        obj.send("date(3i)=", 5)
        expect(obj.date.day).to eq(5)
      end

      it "accepts string" do
        obj.send("date(3i)=", "5")
        expect(obj.date.day).to eq(5)
      end
    end

    describe "mass assignment" do
      context "given all parameters" do
        it "sets all date components" do
          obj = DateWriterTestClass.new("date(1i)" => 2013, "date(2i)" => 10, "date(3i)" => 5)
          expect(obj.date).to eq(Date.new(2013, 10, 5))
        end
      end

      context "given some parameters" do
        it "does not touch missing date components" do
          obj = DateWriterTestClass.new("date(1i)" => 2013, "date(3i)" => 5)
          expect(obj.date).to eq(Date.new(2013, 1, 5))
        end
      end
    end
  end
end
