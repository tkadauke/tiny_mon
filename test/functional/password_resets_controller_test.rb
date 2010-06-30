require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PasswordResetsControllerTest < ActionController::TestCase
  def setup
    @user = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    logout
  end

  test "should get index" do
    get :index
    assert_response :success
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should get edit" do
    # the logout call in the setup method resets the perishable token, so we have to reload the user
    get :edit, :id => @user.reload.perishable_token
    assert_response :success
    assert_nil flash[:error]
  end
  
  test "should not get edit without perishable token" do
    get :edit, :id => nil
    assert_response :redirect
    assert_not_nil flash[:error]
  end
  
  test "should deliver password reset instructions" do
    post :create, :email => 'john.doe@example.com'
    assert_response :redirect
    assert_not_nil flash[:notice]
  end
  
  test "should not deliver password reset instructions if email is invalid" do
    post :create, :email => 'foo@bar.com'
    assert_response :success
    assert_not_nil flash[:error]
  end
  
  test "should update password" do
    post :update, :id => @user.reload.perishable_token, :user => { :password => '54321', :password_confirmation => '54321' }
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert @user.reload.valid_password?('54321')
    assert !@user.reload.valid_password?('12345')
  end
  
  test "should not update invalid password" do
    post :update, :id => @user.reload.perishable_token, :user => { :password => 'a', :password_confirmation => 'a' }
    assert_response :success
    assert_nil flash[:notice]
    assert !@user.reload.valid_password?('a')
    assert @user.reload.valid_password?('12345')
  end
  
  test "should not update password without perishable token" do
    post :update, :id => 'foo', :user => { :password => '54321', :password_confirmation => '54321' }
    assert_response :redirect
    assert_not_nil flash[:error]
    assert !@user.reload.valid_password?('54321')
    assert @user.reload.valid_password?('12345')
  end
end
