require 'test_helper'

class SitesControllerTest < ActionController::TestCase
  test "should show all sites" do
    site = Site.create(:name => 'example.com')
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
      post :create, :site => { :name => 'example.com' }
      assert_response :redirect
    end
  end
  
  test "should show site" do
    site = Site.create(:name => 'example.com')
    get :show, :id => site
    assert_response :success
  end
  
  test "should show edit" do
    site = Site.create(:name => 'example.com')
    get :edit, :id => site
    assert_response :success
  end
  
  test "should update site" do
    site = Site.create(:name => 'example.com')
    post :update, :id => site, :site => { :name => 'something.com' }
    assert_response :redirect
    assert_equal 'something.com', site.reload.name
  end
end
