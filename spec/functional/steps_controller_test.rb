require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class StepsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page', :interval => 1)
    
    login_with @user
  end
  
  test "should show index" do
    step = VisitStep.create(:health_check => @health_check)
    get :index, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param
    assert_response :success
  end
  
  test "should show new" do
    xhr :get, :new, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :type => 'visit'
    assert_response :success
    assert assigns(:step).is_a?(VisitStep)
  end
  
  test "should show edit" do
    step = VisitStep.create(:health_check => @health_check, :url => '/')
    xhr :get, :edit, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :id => step
    assert_response :success
  end
  
  test "should create step" do
    assert_difference 'Step.count' do
      post :create, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :type => 'visit', :visit_step => { :url => '/' }
      assert assigns(:step).is_a?(VisitStep)
      assert_response :redirect
    end
  end
  
  test "should update step" do
    step = VisitStep.create(:health_check => @health_check, :url => '/')
    assert_redirected_back do
      post :update, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :id => step, :visit_step => { :url => '/' }
      assert assigns(:step).is_a?(VisitStep)
      assert_equal '/', step.reload.url
    end
  end
  
  test "should delete step" do
    step = @health_check.steps.create
    assert_difference 'Step.count', -1 do
      assert_redirected_back do
        delete :destroy, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :id => step
      end
    end
  end
  
  test "should sort steps" do
    step1 = @health_check.steps.create
    step2 = @health_check.steps.create
    step3 = @health_check.steps.create
    
    post :sort, :locale => 'en', :account_id => @account, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :step => [step3.id, step1.id, step2.id]
    
    assert_equal 0, step3.reload.position
    assert_equal 1, step1.reload.position
    assert_equal 2, step2.reload.position
  end
end
