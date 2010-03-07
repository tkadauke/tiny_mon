require 'test_helper'

class VisitStepTest < ActiveSupport::TestCase
  test "should get url" do
    step = VisitStep.new(:url => '/')
    runner = mock(:get)
    step.run!(runner)
  end
end
