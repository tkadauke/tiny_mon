require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SitesControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
  end
  
  test "should show all sites" do
    site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    get :index, :account_id => @account
    assert_response :success
    assert_equal [site], assigns(:sites)
  end
  
  test "should show new" do
    get :new, :account_id => @account
    assert_response :success
  end
  
  test "should create site" do
    assert_difference 'Site.count' do
      post :create, :account_id => @account, :site => { :name => 'example.com', :url => 'http://www.example.com' }
      assert_response :redirect
    end
  end
  
  test "should not create invalid site" do
    assert_no_difference 'Site.count' do
      post :create, :account_id => @account, :site => { :name => 'example.com', :url => nil }
      assert_response :success
    end
  end
  
  test "should redirect to health checks when showing site" do
    # def @controller.redirect_to(*args)
    #   puts backtrace
    # end
    
    site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    get :show, :account_id => @account, :id => site.to_param
    assert_response :redirect
  end
  
  test "should show edit" do
    site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    get :edit, :account_id => @account, :id => site.to_param
    assert_response :success
  end
  
  test "should update site" do
    site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    post :update, :account_id => @account, :id => site.to_param, :site => { :name => 'something.com' }
    assert_response :redirect
    assert_equal 'something.com', site.reload.name
  end
  
  test "should not update invalid site" do
    site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    post :update, :account_id => @account, :id => site.to_param, :site => { :name => 'something.com', :url => nil }
    assert_response :success
  end
  
  test "should destroy site" do
    site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    assert_difference 'Site.count', -1 do
      delete :destroy, :account_id => @account, :id => site.to_param
      assert_response :redirect
    end
  end
end
