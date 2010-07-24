require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CheckEmailStepTest < ActiveSupport::TestCase
  test "should check email" do
    step = CheckEmailStep.new(:server => 'mail.gmail.com', :login => 'user@gmail.com', :password => 'foo')
    session = mock(:check_email)
    step.run!(session, stub)
  end
end
