require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::AccountsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account, :role => 'admin')
    
    login_with @user
  end
  
  test "should show index" do
    get :index
    assert_response :success
  end
  
  test "should show account" do
    get :show, :id => @account
    assert_response :success
  end
end
