require 'test_helper'

class HealthChecksControllerTest < ActionController::TestCase
  def setup
    @site = Site.create(:name => 'example.com')
  end
  
  test "should get index" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :index, :site_id => @site
    assert_response :success
    assert_equal [health_check], assigns(:health_checks)
  end
  
  test "should show new" do
    get :new, :site_id => @site
    assert_response :success
  end
  
  test "should create health check" do
    assert_difference 'HealthCheck.count' do
      post :create, :site_id => @site, :health_check => { :name => 'Login' }
      assert_response :redirect
    end
  end
  
  test "should show health check" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :show, :site_id => @site, :id => health_check
  end
  
  test "should get edit" do
    health_check = @site.health_checks.create(:name => 'Home page')
    get :edit, :site_id => @site, :id => health_check
  end
  
  test "should update health check" do
    health_check = @site.health_checks.create(:name => 'Home page')
    post :update, :site_id => @site, :id => health_check, :health_check => { :name => 'Login' }
    assert_response :redirect
    assert_equal 'Login', health_check.reload.name
  end
end
