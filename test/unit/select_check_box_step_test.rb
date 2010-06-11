require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SelectCheckBoxStepTest < ActiveSupport::TestCase
  test "should select check box" do
    step = SelectCheckBoxStep.new(:name => 'Check')
    session = mock(:check)
    step.run!(session)
  end
end
