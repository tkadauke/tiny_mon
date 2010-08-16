require 'test_helper'

class ChooseRadioButtonStepTest < ActiveSupport::TestCase
  test "should choose radio button" do
    step = ChooseRadioButtonStep.new(:name => 'foo')
    session = mock(:choose)
    step.run!(session, stub)
  end
end
