require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class CheckRunsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page', :interval => 10)

    login_with @user
  end
  
  test "should show html index" do
    check_run = @health_check.check_runs.create(:started_at => 2.seconds.ago, :ended_at => Time.now, :status => 'success', :log => [[Time.now, 'Some message']])
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param
    assert_response :success
  end
  
  test "should show html index as xhr" do
    check_run = @health_check.check_runs.create(:started_at => 2.seconds.ago, :ended_at => Time.now, :status => 'success', :log => [[Time.now, 'Some message']])
    xhr :get, :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param
    assert_response :success
  end
  
  test "should show check run" do
    check_run = @health_check.check_runs.create(:started_at => 2.seconds.ago, :ended_at => Time.now, :status => 'success', :log => [[Time.now, 'Some message']])
    get :show, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :id => check_run
    assert_response :success
    assert assigns(:check_run).is_a?(CheckRun)
  end
  
  test "should create check run" do
    assert_difference 'CheckRun.count' do
      post :create, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param
      assert_response :redirect
    end
  end
end
