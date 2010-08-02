require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class AdminControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account, :role => 'admin')
    
    login_with @user
  end
  
  test "should show index" do
    get :index
    assert_response :success
  end
end
