require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ClickButtonStepTest < ActiveSupport::TestCase
  test "should click button" do
    step = ClickButtonStep.new(:name => 'Save')
    session = mock(:click_button)
    step.run!(session, stub)
  end
end
