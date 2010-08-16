require 'test_helper'

class DeselectCheckBoxStepTest < ActiveSupport::TestCase
  test "should deselect check box" do
    step = DeselectCheckBoxStep.new(:name => 'Uncheck')
    session = mock(:uncheck)
    step.run!(session, stub)
  end
  
  test "should deselect check box in scope" do
    step = DeselectCheckBoxStep.new(:name => 'Uncheck', :scope => '.some_class')
    session = mock
    session.expects(:within).yields(mock(:uncheck))
    step.run!(session, stub)
  end
end
