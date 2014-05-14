require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ActionListHelperTest < ActionView::TestCase
  test "should return empty string on empty action list" do
    result = action_list() {|a|}
    assert_equal "", result
  end
  
  test "should build one-item action list" do
    result = action_list do |a|
      a.link_to 'test', 'test'
    end
    assert_equal '<a href="test">test</a>', result
  end
  
  test "should build multi-item action list" do
    result = action_list do |a|
      a.link_to 'test', 'test'
      a.link_to 'test2', 'test2'
    end
    assert_equal '<a href="test">test</a> | <a href="test2">test2</a>', result
  end
  
  test "should raise exception on missing method" do
    assert_raise NoMethodError do
      action_list do |a|
        a.foobar
      end
    end
  end
end
