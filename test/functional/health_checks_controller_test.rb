require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HealthChecksControllerTest < ActionController::TestCase
  def setup
    @site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
  end
  
  test "should get index" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :index, :site_id => @site.to_param
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
  end
  
  test "should update index" do
    health_check = @site.health_checks.create(:name => 'Home page')
    xhr :get, :index, :site_id => @site.to_param
    assert_response :success
  end
  
  test "should get overall index" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :index
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
  end
  
  test "should update overall index" do
    health_check = @site.health_checks.create(:name => 'Home page')
    xhr :get, :index
    assert_response :success
  end
  
  test "should show new" do
    get :new, :site_id => @site.to_param
    assert_response :success
  end
  
  test "should create health check" do
    assert_difference 'HealthCheck.count' do
      post :create, :site_id => @site.to_param, :health_check => { :name => 'Login' }
      assert_response :redirect
    end
  end
  
  test "should not create invalid health check" do
    assert_no_difference 'HealthCheck.count' do
      post :create, :site_id => @site.to_param, :health_check => { :name => nil }
      assert_response :success
    end
  end
  
  test "should show health check" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :show, :site_id => @site.to_param, :id => health_check.to_param
  end
  
  test "should get edit" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :edit, :site_id => @site.to_param, :id => health_check.to_param
  end
  
  test "should update health check" do
    health_check = @site.health_checks.create(:name => 'Home page')
    post :update, :site_id => @site.to_param, :id => health_check.to_param, :health_check => { :name => 'Login' }
    assert_response :redirect
    assert_equal 'Login', health_check.reload.name
  end
  
  test "should not update invalid health check" do
    health_check = @site.health_checks.create(:name => 'Home page')
    post :update, :site_id => @site.to_param, :id => health_check.to_param, :health_check => { :name => nil }
    assert_response :success
  end
end
