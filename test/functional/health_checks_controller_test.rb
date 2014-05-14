require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HealthChecksControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    
    login_with @user
  end
  
  test "should get index" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
  end
  
  test "should get index with report parameter" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :report => 'overview'
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
    assert_equal 'overview', @user.soft_settings.get("health_checks.report")
  end
  
  test "should get index with status filter" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1, :status => 'success', :enabled => true)
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :status => 'success'
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
    assert_equal 'success', @user.soft_settings.get("health_checks.status")
  end
  
  test "should get index with enabled filter" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1, :enabled => false)
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :status => 'disabled'
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
    assert_equal 'disabled', @user.soft_settings.get("health_checks.status")
  end
  
  test "should get index with search filter" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1, :enabled => false)
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :search_filter => { :query => 'Home' }
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
  end
  
  test "should update index" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    xhr :get, :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param
    assert_response :success
  end
  
  test "should get overall index" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    get :index, :locale => 'en', :account_id => @account
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
  end
  
  test "should update overall index" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    xhr :get, :index, :locale => 'en', :account_id => @account
    assert_response :success
  end
  
  test "should show new" do
    get :new, :locale => 'en', :account_id => @account, :site_id => @site.to_param
    assert_response :success
  end
  
  test "should create health check" do
    assert_difference 'HealthCheck.count' do
      post :create, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check => { :name => 'Login', :interval => 1 }
      assert_response :redirect
    end
  end
  
  test "should not create invalid health check" do
    assert_no_difference 'HealthCheck.count' do
      post :create, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check => { :name => nil, :interval => 1 }
      assert_response :success
    end
  end
  
  test "should show health check" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    get :show, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :id => health_check.to_param
  end
  
  test "should get edit" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    get :edit, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :id => health_check.to_param
  end
  
  test "should update health check" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    post :update, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :id => health_check.to_param, :health_check => { :name => 'Login' }
    assert_response :redirect
    assert_equal 'Login', health_check.reload.name
  end
  
  test "should not update invalid health check" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    post :update, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :id => health_check.to_param, :health_check => { :name => nil }
    assert_response :success
  end
  
  test "should delete health check" do
    health_check = @site.health_checks.create(:name => 'Home page', :interval => 1)
    assert_difference 'HealthCheck.count', -1 do
      delete :destroy, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :id => health_check.to_param
      assert_response :redirect
    end
  end
  
  test "should edit multiple health checks" do
    health_check1 = @site.health_checks.create(:name => 'Home page', :interval => 1)
    health_check2 = @site.health_checks.create(:name => 'About page', :interval => 1)
    
    post :edit_multiple, :locale => 'en', :health_check_ids => [health_check1.id, health_check2.id]
    assert_response :success
  end
  
  test "should update multiple health checks" do
    health_check1 = @site.health_checks.create(:name => 'Home page', :interval => 1)
    health_check2 = @site.health_checks.create(:name => 'About page', :interval => 1)

    put :update_multiple, :locale => 'en', :health_check_ids => [health_check1.id, health_check2.id], :health_check => { :bulk_update_interval => '1', :interval => 60 }
    
    assert_response :redirect
    assert_not_nil flash[:notice]
    
    assert_equal 60, health_check1.reload.interval
    assert_equal 60, health_check2.reload.interval
  end
  
  test "should not update unselected fields when updating multiple health checks" do
    health_check1 = @site.health_checks.create(:name => 'Home page', :interval => 1)
    health_check2 = @site.health_checks.create(:name => 'About page', :interval => 1)

    put :update_multiple, :locale => 'en', :health_check_ids => [health_check1.id, health_check2.id], :health_check => { :bulk_update_interval => '0', :interval => 1 }
    
    assert_response :redirect
    assert_not_nil flash[:notice]
    
    assert_equal 1, health_check1.reload.interval
    assert_equal 1, health_check2.reload.interval
  end
end
