require 'test_helper'

class TakeScreenshotStepTest < ActiveSupport::TestCase
  test "should take screenshot" do
    step = TakeScreenshotStep.new
    screenshot_mock = Screenshot.new
    screenshot_mock.expects(:save)
    
    session = mock(:take_screenshot => screenshot_mock)
    step.run!(session, CheckRun.new)
  end
end
