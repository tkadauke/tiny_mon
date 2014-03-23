require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClickButtonStepTest < ActiveSupport::TestCase
  test "should click button" do
    step = ClickButtonStep.new(:name => 'Save')
    session = mock(:click_button)
    step.run!(session, stub)
  end
  
  test "should click button in scope" do
    step = ClickButtonStep.new(:name => 'Save', :scope => '.some_class')
    session = mock
    session.expects(:within)
    step.run!(session, stub)
  end
end
