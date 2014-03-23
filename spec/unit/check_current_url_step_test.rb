require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class CheckCurrentUrlStepTest < ActiveSupport::TestCase
  test "should raise nothing if url is as expected" do
    session = stub(:driver => stub(:current_url => 'http://www.example.com/some?url'), :log => nil)
    step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/some?url')
    assert_nothing_raised do
      step.run!(session, stub)
    end
  end

  test "should raise if url is not as expected" do
    session = stub(:driver => stub(:current_url => 'http://www.example.com/some?url'), :log => nil)
    session.expects(:fail)
    step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/foobar')
    step.run!(session, stub)
  end

  test "should raise if url as expected in negate mode" do
    session = stub(:driver => stub(:current_url => 'http://www.example.com/some?url'), :log => nil)
    session.expects(:fail)
    step = CheckCurrentUrlStep.new(:url => 'http://www.example.com/some?url', :negate => true)
    step.run!(session, stub)
  end
end
