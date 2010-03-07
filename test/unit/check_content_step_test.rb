require 'test_helper'

class CheckContentStepTest < ActiveSupport::TestCase
  test "should raise nothing if content is present" do
    runner = stub(:response => stub(:body => 'something with interesting content'))
    step = CheckContentStep.new(:content => 'interesting')
    assert_nothing_raised do
      step.run!(runner)
    end
  end

  test "should raise if content is not present" do
    runner = stub(:response => stub(:body => 'something with interesting content'))
    step = CheckContentStep.new(:content => 'not present')
    assert_raise CheckContentStep::ContentCheckFailed do
      step.run!(runner)
    end
  end
end
