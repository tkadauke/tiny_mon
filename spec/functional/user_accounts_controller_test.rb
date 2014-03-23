require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class UserAccountsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @user.set_role_for_account(@account, 'admin')
    
    login_with @user
  end

  test "should get new" do
    get :new, :locale => 'en', :account_id => @account
    assert_response :success
  end
  
  test "should create user account mapping" do
    second_user = User.create(:full_name => 'Jane Doe', :email => 'jane.doe@example.com', :password => '12345', :password_confirmation => '12345')
    assert_difference 'UserAccount.count' do
      assert !second_user.can_switch_to_account?(@account)
      post :create, :locale => 'en', :account_id => @account, :user_account => { :email => 'jane.doe@example.com' }
      assert_response :redirect
      assert_not_nil flash[:notice]
      assert second_user.can_switch_to_account?(@account)
    end
  end
  
  test "should set current account when account mapping is created if user has no account" do
    second_user = User.create(:full_name => 'Jane Doe', :email => 'jane.doe@example.com', :password => '12345', :password_confirmation => '12345')
    assert_nil second_user.current_account
    post :create, :locale => 'en', :account_id => @account, :user_account => { :email => 'jane.doe@example.com' }
    assert_not_nil second_user.reload.current_account
  end
  
  test "should not set current account when account mapping is created if user already has an account" do
    new_account = Account.create(:name => 'another')
    second_user = User.create(:current_account => new_account, :full_name => 'Jane Doe', :email => 'jane.doe@example.com', :password => '12345', :password_confirmation => '12345')
    
    post :create, :locale => 'en', :account_id => @account, :user_account => { :email => 'jane.doe@example.com' }
    assert_equal new_account, second_user.reload.current_account
  end
  
  test "should not create user account mapping if user does not exist" do
    assert_no_difference 'UserAccount.count' do
      post :create, :locale => 'en', :account_id => @account, :user_account => { :email => 'foo@bar.com' }
      assert_response :success
      assert_nil flash[:notice]
      assert assigns(:user_account).errors[:email]
    end
  end
  
  test "should update user account mapping" do
    second_user = @account.users.create(:full_name => 'Jane Doe', :email => 'jane.doe@example.com', :password => '12345', :password_confirmation => '12345')

    post :update, :locale => 'en', :account_id => @account, :id => UserAccount.last, :user_account => { :role => 'admin' }
    assert_response :redirect
    assert_not_nil flash[:notice]
  end

  test "should remove user account mapping" do
    second_user = @account.users.create(:full_name => 'Jane Doe', :email => 'jane.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    assert_difference 'UserAccount.count', -1 do
      delete :destroy, :locale => 'en', :account_id => @account, :id => UserAccount.last
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
end
