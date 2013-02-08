require 'test_helper'

class TutorialsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
  end
  
  test "should start tutorial" do
    assert_redirected_back do
      post :create, :locale => 'en', :id => 'test_tutorial'
      assert_equal 'test_tutorial', @user.soft_settings.get("tutorials.current")
    end
  end
  
  test "should finish tutorial" do
    assert_redirected_back do
      delete :destroy, :locale => 'en'
      assert_nil @user.soft_settings.get("tutorials.current")
    end
  end
end
