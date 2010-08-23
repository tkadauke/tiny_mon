class CheckRunsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  before_filter :find_health_check
  before_filter :create_check_run_filter, :only => :index
  active_tab :health_checks
  
  def index
    @check_runs = @health_check.check_runs.recent.paginate(:page => params[:page], :include => :health_check, :conditions => @check_run_filter.conditions)
    render :partial => "/check_runs/activity" if request.xhr?
  end
  
  def show
    @check_run = @health_check.check_runs.find(params[:id])
    @comment = @check_run.comments.build
    @comments = @check_run.latest_comments.find(:all, :limit => 5)
    @comments_count = @check_run.comments.count
    
    @screenshots = @check_run.screenshots
    @screenshot_comparisons = @check_run.screenshot_comparisons
  end
  
  def create
    can_run_health_checks!(@account) do
      @check_run = @health_check.check!(current_user)
      redirect_to account_site_health_check_check_run_path(@account, @site, @health_check, @check_run)
    end
  end
  
protected
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id])
  end

  def find_health_check
    @health_check = @site.health_checks.find_by_permalink!(params[:health_check_id])
  end
  
  def create_check_run_filter
    if params[:check_run_filter]
      @check_run_filter = CheckRunFilter.new(params[:check_run_filter])
    end
    
    if !params[:check_run_filter] || !@check_run_filter.valid?
      if first_check_run = @health_check.check_runs.first
        @check_run_filter = CheckRunFilter.new(:start_date => first_check_run.created_at, :end_date => Date.today)
      else
        @check_run_filter = CheckRunFilter.new
      end
    end
  end
end
