require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class StepTest < ActiveSupport::TestCase
  test "should not run" do
    assert_raise NotImplementedError do
      Step.new.run!(stub, stub)
    end
  end
end
