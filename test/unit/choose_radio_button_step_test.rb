require 'test_helper'

class ChooseRadioButtonStepTest < ActiveSupport::TestCase
  test "should choose radio button" do
    step = ChooseRadioButtonStep.new(:name => 'foo')
    session = mock(:choose)
    step.run!(session, stub)
  end
  
  test "should choose radio button in scope" do
    step = ChooseRadioButtonStep.new(:name => 'foo', :scope => '.some_class')
    session = mock
    session.expects(:within).yields(mock(:choose))
    step.run!(session, stub)
  end
end
