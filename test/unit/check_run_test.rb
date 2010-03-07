require 'test_helper'

class CheckRunTest < ActiveSupport::TestCase
  test "should calculate duration" do
    check_run = CheckRun.new(:started_at => 2.seconds.ago, :ended_at => Time.now)
    assert_equal 2, check_run.duration.to_i
  end
end
