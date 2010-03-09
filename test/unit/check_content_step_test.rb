require 'test_helper'

class CheckContentStepTest < ActiveSupport::TestCase
  test "should raise nothing if content is present" do
    session = stub(:response => stub(:body => 'something with interesting content'), :log => nil)
    step = CheckContentStep.new(:content => 'interesting')
    assert_nothing_raised do
      step.run!(session)
    end
  end

  test "should raise if content is not present" do
    session = stub(:response => stub(:body => 'something with interesting content'), :log => nil)
    session.expects(:fail)
    step = CheckContentStep.new(:content => 'not present')
    step.run!(session)
  end
end
