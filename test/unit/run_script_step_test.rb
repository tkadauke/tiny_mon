require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class RunScriptStepTest < ActiveSupport::TestCase
  test "should run script" do
    step = RunScriptStep.new
    session = mock(:execute_script => nil)
    step.run!(session, stub)
  end
end
