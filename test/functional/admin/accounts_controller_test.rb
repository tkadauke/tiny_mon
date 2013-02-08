require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::AccountsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @user.role = 'admin'
    @user.save
    
    login_with @user
  end
  
  test "should show index" do
    get :index, :locale => 'en'
    assert_response :success
  end
  
  test "should show account" do
    get :show, :locale => 'en', :id => @account
    assert_response :success
  end
  
  test "should show edit" do
    get :edit, :locale => 'en', :id => @account
    assert_response :success
  end
  
  test "should update account" do
    post :update, :locale => 'en', :id => @account, :account => { :maximum_check_runs_per_day => 1000 }
    assert_response :redirect
    assert_equal 1000, @account.reload.maximum_check_runs_per_day
  end
end
