require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class VisitStepTest < ActiveSupport::TestCase
  test "should get url" do
    step = VisitStep.new(:url => '/')
    session = mock(:visit)
    step.run!(session)
  end
end
