require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ToBoolTest < ActionView::TestCase
  test "should be true by default" do
    assert Object.new.to_bool
  end
  
  test "should be false for nil" do
    assert ! nil.to_bool
  end
  
  test "should be false for false" do
    assert ! false.to_bool
  end
  
  test "should be true for true" do
    assert true.to_bool
  end
  
  test "should be false for 0" do
    assert ! 0.to_bool
  end
  
  test "should be true for other numbers" do
    assert 1.to_bool
    assert 17.5.to_bool
  end
  
  test "should be true for '1' or 'true'" do
    assert '1'.to_bool
    assert 'true'.to_bool
    assert 'TRUE'.to_bool
  end
  
  test "should be false for other strings" do
    assert ! '0'.to_bool
    assert ! 'false'.to_bool
  end
end
