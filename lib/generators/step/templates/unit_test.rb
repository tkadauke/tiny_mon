require 'test_helper'

class <%= class_name %>StepTest < ActiveSupport::TestCase
  test "should <%= file_name.gsub('_', ' ') %>" do
    step = <%= class_name %>Step.new
    session = mock
    step.run!(session, stub)
  end
end
