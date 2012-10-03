require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CompareScreenshotsStepTest < ActiveSupport::TestCase
  test "should compare screenshots if check run is not first in deployment" do
    check_run_mock = CheckRun.new
    check_run_mock.expects(:first_in_deployment? => false)
    
    step = CompareScreenshotsStep.new
    session = mock(:compare_screenshots => ScreenshotComparison.new)
    
    step.run!(session, check_run_mock)
  end

  test "should not compare screenshots if check run is first in deployment" do
    check_run_mock = CheckRun.new
    check_run_mock.expects(:first_in_deployment? => true)
    
    step = CompareScreenshotsStep.new
    step.run!(stub, check_run_mock)
  end
end
