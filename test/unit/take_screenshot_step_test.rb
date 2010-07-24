require 'test_helper'

class TakeScreenshotStepTest < ActiveSupport::TestCase
  test "should take screenshot" do
    step = TakeScreenshotStep.new
    session = mock(:take_screenshot)
    check_run = stub(:screenshots => mock(:create))
    step.run!(session, check_run)
  end
end
