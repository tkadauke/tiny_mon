require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CheckContentStepTest < ActiveSupport::TestCase
  test "should raise nothing if content is present" do
    session = stub(:response => stub(:body => 'something with interesting content', :encoding => 'UTF-8'), :log => nil)
    step = CheckContentStep.new(:content => 'interesting')
    assert_nothing_raised do
      step.run!(session)
    end
  end

  test "should raise if content is not present" do
    session = stub(:response => stub(:body => 'something with interesting content', :encoding => 'UTF-8'), :log => nil)
    session.expects(:fail)
    step = CheckContentStep.new(:content => 'not present')
    step.run!(session)
  end
  
  test "should transcode response body to utf-8 before checking content" do
    Iconv.expects(:conv).returns('something with interesting content')

    session = stub(:response => stub(:body => 'something with interesting content', :encoding => 'ISO-8859-1'), :log => nil)
    step = CheckContentStep.new(:content => 'interesting')
    assert_nothing_raised do
      step.run!(session)
    end
  end
end
