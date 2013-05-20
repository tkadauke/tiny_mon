require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class BroadcastTest < ActiveSupport::TestCase
  test "should validate" do
    assert ! Broadcast.new.valid?
    assert   Broadcast.new(:title => 'Hello', :text => 'World').valid?
  end
  
  test "should have title as name" do
    assert_equal 'Hello', Broadcast.new(:title => 'Hello').name
  end
  
  test "should get broadcast from param" do
    Broadcast.expects(:find).with(10)
    Broadcast.from_param!(10)
  end
end
