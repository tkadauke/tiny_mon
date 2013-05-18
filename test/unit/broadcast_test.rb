require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BroadcastTest < ActiveSupport::TestCase
  test "should validate" do
    assert ! Broadcast.new.valid?
    assert   Broadcast.new(:title => 'Hello', :text => 'World').valid?
  end
end
