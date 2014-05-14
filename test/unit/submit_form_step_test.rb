require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SubmitFormStepTest < ActiveSupport::TestCase
  test "should submit form" do
    step = SubmitFormStep.new
    session = mock(:log => nil, :submit_form => nil)
    step.run!(session, stub)
  end
end
