class ScreenshotComparisonsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  before_filter :find_health_check
  before_filter :find_check_run
  
  def index
    redirect_to account_site_health_check_check_run_path(@account, @site, @health_check, @check_run)
  end

  def show
    @screenshot_comparison = ScreenshotComparison.find(params[:id])
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
