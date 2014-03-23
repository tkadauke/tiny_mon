require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ClickEmailLinkStepTest < ActiveSupport::TestCase
  test "should click email link" do
    step = ClickEmailLinkStep.new(:link_pattern => 'http://google.com')
    session = mock(:click_email_link)
    step.run!(session, stub)
  end
end
