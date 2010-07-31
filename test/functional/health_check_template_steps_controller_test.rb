require 'test_helper'

class HealthCheckTemplateStepsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
  end
  
  test "should get new" do
    xhr :get, :new
    assert_response :success
  end
end
