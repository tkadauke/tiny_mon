require 'test_helper'

class CheckStatusStepTest < ActiveSupport::TestCase
  test "should raise nothing if status is correct" do
    session = stub(:response => stub(:code => '200'), :log => nil)
    step = CheckStatusStep.new(:status => 200)
    assert_nothing_raised do
      step.run!(session)
    end
  end

  test "should raise if content is not present" do
    session = stub(:response => stub(:code => '404'), :log => nil)
    session.expects(:fail)
    step = CheckStatusStep.new(:status => 200)
    step.run!(session)
  end
end
