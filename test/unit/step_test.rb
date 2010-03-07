require 'test_helper'

class StepTest < ActiveSupport::TestCase
  test "should not run" do
    assert_raise NotImplementedError do
      Step.new.run!(stub)
    end
  end
end
