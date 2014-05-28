class ScreenshotsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  before_filter :find_health_check
  before_filter :find_check_run, :only => :show
  
  def index
    @screenshots = @health_check.latest_screenshots.paginate :page => (params[:page] || 1), :per_page => 15
    @page_title = t(".screenshots_of_health_check", :health_check => @health_check.name)
  end

  def show
    @screenshot = @check_run.screenshots.find(params[:id])
    @page_title = t('.screenshot_for_check_run_health_check_site', :check_run => @check_run.id, :health_check => @health_check.name, :site => @site.name)
  end
  
protected
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id])
  end

  def find_health_check
    @health_check = @site.health_checks.find_by_permalink!(params[:health_check_id])
  end
  
  def find_check_run
    @check_run = @health_check.check_runs.find(params[:check_run_id])
  end
end
