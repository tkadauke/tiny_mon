require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ClickLinkStepTest < ActiveSupport::TestCase
  test "should click button" do
    step = ClickLinkStep.new(:name => 'Save')
    session = mock(:click_link)
    step.run!(session)
  end
end
