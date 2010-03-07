require 'test_helper'

class CheckRunTest < ActiveSupport::TestCase
  test "should calculate duration" do
    check_run = CheckRun.new(:started_at => 2.seconds.ago.to_f, :ended_at => Time.now.to_f)
    assert_equal 2, check_run.duration.to_i
  end
end
