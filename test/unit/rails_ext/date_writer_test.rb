require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class DateWriterTest < ActiveSupport::TestCase
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

  test "should define year setter" do
    obj = DateWriterTestClass.new
    obj.send("date(1i)=", 2013)
    assert_equal 2013, obj.date.year
  end

  test "should accept year string" do
    obj = DateWriterTestClass.new
    obj.send("date(1i)=", "2013")
    assert_equal 2013, obj.date.year
  end

  test "should define month setter" do
    obj = DateWriterTestClass.new
    obj.send("date(2i)=", 10)
    assert_equal 10, obj.date.month
  end

  test "should accept month string" do
    obj = DateWriterTestClass.new
    obj.send("date(2i)=", "10")
    assert_equal 10, obj.date.month
  end

  test "should define day setter" do
    obj = DateWriterTestClass.new
    obj.send("date(3i)=", 5)
    assert_equal 5, obj.date.day
  end

  test "should accept day string" do
    obj = DateWriterTestClass.new
    obj.send("date(3i)=", "5")
    assert_equal 5, obj.date.day
  end

  test "should work together with mass assignment" do
    obj = DateWriterTestClass.new("date(1i)" => 2013, "date(2i)" => 10, "date(3i)" => 5)
    assert_equal Date.new(2013, 10, 5), obj.date
  end
end
