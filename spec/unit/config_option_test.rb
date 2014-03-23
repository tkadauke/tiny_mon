require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ConfigOptionTest < ActiveSupport::TestCase
  test "should validate" do
    assert ! ConfigOption.new.valid?
    assert   ConfigOption.new(:key => 'some_key').valid?
  end
end
