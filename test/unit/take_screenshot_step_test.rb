require 'test_helper'

class TakeScreenshotStepTest < ActiveSupport::TestCase
  test "should take screenshot" do
    step = TakeScreenshotStep.new
    session = mock
    step.run!(session)
  end
end
