require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class AccountTest < ActiveSupport::TestCase
  test "should update check runs per day" do
    account = Account.create!(:name => 'some account')
    site = account.sites.create!(:name => 'some_site', :url => 'http://www.example.com')
    health_check1 = site.health_checks.create!(:name => 'some_check', :interval => 60) # 24 per day
    health_check2 = site.health_checks.create!(:name => 'some_other_check', :interval => 120) # 12 per day
    
    account.update_check_runs_per_day
    
    assert_equal 36, account.reload.check_runs_per_day
  end
  
  test "should update attributes without protection" do
    account = Account.create!(:name => 'some account')
    assert_not_equal 0, account.maximum_check_runs_per_day
    account.update_attributes_without_attr_protected(:maximum_check_runs_per_day => 0)
    assert_equal 0, account.reload.maximum_check_runs_per_day
  end
  
  test "should figure out if there are unlimited check runs" do
    account = Account.new
    account.maximum_check_runs_per_day = 0
    assert account.unlimited_check_runs?
  end
  
  test "should figure out if scheduled health checks are over check run limit" do
    account = Account.new
    account.check_runs_per_day = 50
    account.maximum_check_runs_per_day = 40
    assert account.over_maximum_check_runs_per_day?
  end
  
  test "should figure out that scheduled health checks are not over check run limit for unlimited account" do
    account = Account.new
    account.check_runs_per_day = 50
    account.maximum_check_runs_per_day = 0
    assert ! account.over_maximum_check_runs_per_day?
  end
  
  test "should figure out if health checks today are over check run limit" do
    CheckRun.stubs(:count).returns(50)
    
    account = Account.new
    account.maximum_check_runs_per_day = 40
    assert account.over_maximum_check_runs_today?
  end
  
  test "should figure out that health checks today are not over check run limit for unlimited account" do
    CheckRun.stubs(:count).returns(50)
    
    account = Account.new
    account.maximum_check_runs_per_day = 0
    assert ! account.over_maximum_check_runs_today?
  end
end
