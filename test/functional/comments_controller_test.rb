require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CommentsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page', :interval => 10)
    @check_run = @health_check.check_runs.create

    login_with @user
  end

  test "should show comments from check run" do
    comment = @check_run.comments.create(:text => 'foobar', :user => @user)
    get :index, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id
    assert_response :success
    
    assert_match /foobar/, @response.body
  end
  
  test "should show comments from health check" do
    comment = @check_run.comments.create(:text => 'foobar', :user => @user)
    get :index, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink
    assert_response :success
    
    assert_match /foobar/, @response.body
  end
  
  test "should show comments by user" do
    comment = @check_run.comments.create(:text => 'foobar', :user => @user)
    get :index, :locale => 'en', :user_id => @user.id
    assert_response :success
    
    assert_match /foobar/, @response.body
  end
  
  test "should create comment" do
    assert_difference 'Comment.count' do
      post :create, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id, :comment => { :text => 'foobar' }
      assert_response :redirect
    end
  end
  
  test "should get new" do
    get :new, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id
    assert_response :success
  end
end
