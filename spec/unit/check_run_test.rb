require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class CheckRunTest < ActiveSupport::TestCase
  test "should calculate duration" do
    check_run = CheckRun.new(:started_at => 2.seconds.ago.to_f, :ended_at => Time.now.to_f)
    assert_equal 2, check_run.duration.to_i
  end
  
  test "should not send notifications if check was triggered by user" do
    check_run = CheckRun.new(:user => User.new)
    assert !check_run.send(:send_notification?)
  end
  
  test "should not send notifications if health check is disabled" do
    check_run = CheckRun.new(:user => nil, :health_check => HealthCheck.new(:enabled => false))
    assert !check_run.send(:send_notification?)
  end
  
  test "should not send notifications if previous check had the same status" do
    check_run = CheckRun.new(:user => nil, :health_check => HealthCheck.new(:enabled => true), :status => 'failure')
    check_run.expects(:previous_check_run).returns(CheckRun.new(:status => 'failure'))
    assert !check_run.send(:send_notification?)
  end
  
  test "should send notifications if the automatic enabled health check had a status change" do
    check_run = CheckRun.new(:user => nil, :health_check => HealthCheck.new(:enabled => true), :status => 'failure')
    check_run.expects(:previous_check_run).returns(CheckRun.new(:status => 'success'))
    assert check_run.send(:send_notification?)
  end
end
