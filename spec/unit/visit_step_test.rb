require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class VisitStepTest < ActiveSupport::TestCase
  test "should get url" do
    step = VisitStep.new(:url => '/')
    session = mock(:visit)
    step.run!(session, stub)
  end
end
