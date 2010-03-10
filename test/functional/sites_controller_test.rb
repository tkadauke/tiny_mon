require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class SitesControllerTest < ActionController::TestCase
  test "should show all sites" do
    site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
    get :index
    assert_response :success
    assert_equal [site], assigns(:sites)
  end
  
  test "should show new" do
    get :new
    assert_response :success
  end
  
  test "should create site" do
    assert_difference 'Site.count' do
      post :create, :site => { :name => 'example.com', :url => 'http://www.example.com' }
      assert_response :redirect
    end
  end
  
  test "should not create invalid site" do
    assert_no_difference 'Site.count' do
      post :create, :site => { :name => 'example.com', :url => nil }
      assert_response :success
    end
  end
  
  test "should redirect to health checks when showing site" do
    site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
    get :show, :id => site.to_param
    assert_response :redirect
  end
  
  test "should show edit" do
    site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
    get :edit, :id => site.to_param
    assert_response :success
  end
  
  test "should update site" do
    site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
    post :update, :id => site.to_param, :site => { :name => 'something.com' }
    assert_response :redirect
    assert_equal 'something.com', site.reload.name
  end
  
  test "should not update invalid site" do
    site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
    post :update, :id => site.to_param, :site => { :name => 'something.com', :url => nil }
    assert_response :success
  end
  
  test "should destroy site" do
    site = Site.create(:name => 'example.com', :url => 'http://www.example.com')
    assert_difference 'Site.count', -1 do
      delete :destroy, :id => site.to_param
      assert_response :redirect
    end
  end
end
