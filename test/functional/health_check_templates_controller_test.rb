require 'test_helper'

class HealthCheckTemplatesControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
  end
  
  test "should get index" do
    template = @user.health_check_templates.create(:name => 'Test template', :name_template => 'Testtest', :interval => 60, :account => @account)
    
    get :index
    assert_response :success
    assert_match /Test template/, @response.body
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should get edit" do
    template = @user.health_check_templates.create(:name => 'Test template', :name_template => 'Testtest', :interval => 60, :account => @account)
    
    get :edit, :id => template
    assert_response :success
  end
  
  test "should create template" do
    assert_difference 'HealthCheckTemplate.count' do
      post :create, :health_check_template => { :name => 'Test template', :name_template => 'Testtest', :interval => 60 }
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
  
  test "should not create invalid template" do
    assert_no_difference 'HealthCheckTemplate.count' do
      post :create, :health_check_template => { :name => 'Test template', :name_template => 'Testtest' }
      assert_response :success
      assert_nil flash[:notice]
    end
  end
  
  test "should update template" do
    template = @user.health_check_templates.create(:name => 'Test template', :name_template => 'Testtest', :interval => 60, :account => @account)
    
    post :update, :id => template, :health_check_template => { :name => 'Test template', :name_template => 'Test' }
    assert_response :redirect
    
    assert_equal 'Test', template.reload.name_template
  end
  
  test "should destroy template" do
    template = @user.health_check_templates.create(:name => 'Test template', :name_template => 'Testtest', :interval => 60, :account => @account)
    
    assert_difference 'HealthCheckTemplate.count', -1 do
      delete :destroy, :id => template
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
end
