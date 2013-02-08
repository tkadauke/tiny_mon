require 'test_helper'

class ScreenshotComparisonsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page', :interval => 10)
    @check_run = @health_check.check_runs.create

    login_with @user
  end
  
  test "should show screenshot comparison" do
    screenshot1 = @check_run.screenshots.create(:checksum => '1234567890abcdef', :file => MockScreenshotFile.new)
    screenshot2 = @check_run.screenshots.create(:checksum => 'fedcba0987654321', :file => MockScreenshotFile.new)
    
    comparison = @check_run.screenshot_comparisons.create(:first_screenshot => screenshot1, :second_screenshot => screenshot2, :checksum => 'abcdef0123456789', :file => MockScreenshotFile.new)
    
    get :show, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :health_check_id => @health_check.permalink, :check_run_id => @check_run.id, :id => comparison.id
    assert_response :success
  end
end
