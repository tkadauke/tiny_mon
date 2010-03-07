require 'test_helper'

class CheckStatusStepTest < ActiveSupport::TestCase
  test "should raise nothing if status is correct" do
    runner = stub(:response => stub(:code => '200'), :log => nil)
    step = CheckStatusStep.new(:status => 200)
    assert_nothing_raised do
      step.run!(runner)
    end
  end

  test "should raise if content is not present" do
    runner = stub(:response => stub(:code => '404'), :log => nil)
    step = CheckStatusStep.new(:status => 200)
    assert_raise CheckStatusStep::StatusCheckFailed do
      step.run!(runner)
    end
  end
end
