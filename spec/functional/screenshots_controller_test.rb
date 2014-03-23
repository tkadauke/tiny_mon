require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class ScreenshotsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page', :interval => 10)
    @check_run = @health_check.check_runs.create

    login_with @user
  end
  
  test "should show all screenshots of health check" do
    screenshot1 = @check_run.screenshots.create(:checksum => '1234567890abcdef', :file => MockScreenshotFile.new)
    screenshot2 = @check_run.screenshots.create(:checksum => 'fedcba0987654321', :file => MockScreenshotFile.new)
    
    get :index, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id
    assert_response :success
  end

  test "should show screenshot" do
    screenshot = @check_run.screenshots.create(:checksum => '1234567890abcdef', :file => MockScreenshotFile.new)
    
    get :show, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id, :id => screenshot
    assert_response :success
  end
end
