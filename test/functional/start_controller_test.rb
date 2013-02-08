require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class StartControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
  end
  
  test "should get index" do
    get :index, :locale => 'en'
    assert_response :success
    assert assigns(:check_runs)
  end
  
  test "should update index" do
    xhr :get, :index, :locale => 'en'
    assert_response :success
    assert assigns(:check_runs)
  end
end
