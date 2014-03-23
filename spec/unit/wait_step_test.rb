require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class WaitStepTest < ActiveSupport::TestCase
  test "should wait" do
    step = WaitStep.new(:duration => 10)
    step.expects(:sleep).with(10)
    step.run!(stub, stub)
  end
end
