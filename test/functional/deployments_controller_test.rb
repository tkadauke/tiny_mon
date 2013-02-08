require 'test_helper'

class DeploymentsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    
    login_with @user
  end

  test "should get index" do
    deployment = @site.deployments.create
    
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.permalink
    assert_response :success
  end
  
  test "should get new" do
    get :new, :locale => 'en', :account_id => @account, :site_id => @site.permalink
    assert_response :success
  end
  
  test "should show deployment" do
    deployment = @site.deployments.create
    get :show, :locale => 'en', :account_id => @account, :site_id => @site.permalink, :id => deployment
    assert_response :success
  end
  
  test "should create deployment" do
    assert_difference 'Deployment.count' do
      post :create, :locale => 'en', :account_id => @account, :site_id => @site.permalink
      assert_response :redirect
    end
  end
  
  test "should create deployment with token" do
    assert_difference 'Deployment.count' do
      post :create, :locale => 'en', :token => @site.deployment_token
      assert_response :redirect
    end
  end
end
