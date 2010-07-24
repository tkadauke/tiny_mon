require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ScreenshotsControllerTest < ActionController::TestCase
  class MockScreenshotFile < ScreenshotFile
    def initialize
    end
    
    def retain
    end
    
    def release
    end
  end
  
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page', :interval => 10)
    @check_run = @health_check.check_runs.create

    login_with @user
  end

  test "should show screenshot" do
    screenshot = @check_run.screenshots.create(:checksum => '1234567890abcdef', :file => MockScreenshotFile.new)
    
    get :show, :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id, :id => screenshot
    assert_response :success
  end
end
