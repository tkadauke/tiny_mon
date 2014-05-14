require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ClickLinkStepTest < ActiveSupport::TestCase
  test "should click link" do
    step = ClickLinkStep.new(:name => 'View it!')
    session = mock(:click_link)
    step.run!(session, stub)
  end
  
  test "should click link in scope" do
    step = ClickLinkStep.new(:name => 'View it!', :scope => '.some_class')
    session = mock
    session.expects(:within)
    step.run!(session, stub)
  end
end
