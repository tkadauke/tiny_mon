require 'test_helper'

class CheckRunsControllerTest < ActionController::TestCase
  def setup
    @site = Site.create(:name => 'example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page')
  end
  
  test "should show check run" do
    check_run = @health_check.check_runs.create(:started_at => 2.seconds.ago, :ended_at => Time.now, :status => 'success', :log => [[Time.now, 'Some message']])
    get :show, :site_id => @site.to_param, :health_check_id => @health_check.to_param, :id => check_run
    assert_response :success
    assert assigns(:check_run).is_a?(CheckRun)
  end
end
