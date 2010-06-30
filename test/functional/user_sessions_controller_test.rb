require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UserSessionsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create user session" do
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    
    post :create, :user_session => { :email => 'john.doe@example.com', :password => '12345' }
    assert user_session = UserSession.find
    assert_equal john, user_session.user
    assert_redirected_to root_path
  end
  
  test "should not create invalid user session" do
    post :create, :user_session => { :email => 'foo@bar.com', :password => '54321' }
    assert ! UserSession.find
    assert_response :success
  end
  
  test "should destroy user session" do
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    
    login_with john
    
    delete :destroy
    assert_nil UserSession.find
    assert_redirected_to root_path
  end
end
