require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SelectCheckBoxStepTest < ActiveSupport::TestCase
  test "should select check box" do
    step = SelectCheckBoxStep.new(:name => 'Check')
    session = mock(:check)
    step.run!(session, stub)
  end
  
  test "should select check box in scope" do
    step = SelectCheckBoxStep.new(:name => 'Check', :scope => '.some_class')
    session = mock
    session.expects(:within)
    step.run!(session, stub)
  end
end
