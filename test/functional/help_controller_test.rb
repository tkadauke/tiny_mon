require 'test_helper'

class HelpControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
  end
  
  test "should turn on help" do
    assert_redirected_back do
      post :create
      assert_equal '1', @user.soft_settings.get("help.show")
    end
  end
  
  test "should turn off help" do
    assert_redirected_back do
      delete :destroy
      assert_equal '0', @user.soft_settings.get("help.show")
    end
  end
end
