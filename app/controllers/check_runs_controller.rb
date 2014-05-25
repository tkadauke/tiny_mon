class CheckRunsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site, :except => :recent
  before_filter :find_health_check, :except => :recent
  before_filter :create_check_run_filter, :only => :index
  active_tab :health_checks
  
  respond_to :html, :xml, :json
  
  def index
    @check_run_filter.health_check_id = @health_check.id if @health_check
    @check_runs = @health_check.check_runs.recent.paginate(:page => params[:page], :include => :health_check, :conditions => @check_run_filter.conditions)
    @page_title = t('.check_runs_of_health_check_site', :health_check => @health_check.name, :site => @site.name)

    respond_with @check_runs do |format|
      format.html do
        render :partial => "/check_runs/activity" if request.xhr?
      end
    end
  end
  
  def recent
    @check_runs = @account.check_runs.recent.includes(:health_check => { :site => :account })
    respond_with @check_runs, :include => :health_check
  end
  
  def show
    @check_run = @health_check.check_runs.find(params[:id])
    @comment = @check_run.comments.build
    @comments = @check_run.latest_comments.limit(5)
    @comments_count = @check_run.comments.count
    
    @screenshots = @check_run.screenshots
    @screenshot_comparisons = @check_run.screenshot_comparisons

    @page_title = t('.check_run_of_health_check_site', :health_check => @health_check.name, :site => @site.name)
    if request.xhr?
      render :partial => "/check_runs/details"
    else
      respond_with @check_run
    end
  end
  
  def create
    can_run_health_checks!(@account) do
      @check_run = @health_check.check!(current_user)
      respond_with @check_run, :location => account_site_health_check_check_run_path(@account, @site, @health_check, @check_run)
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
     #explicit convertion of params to date objects
      start_date = Date.civil(params[:check_run_filter][:"start_date(1i)"].to_i,params[:check_run_filter][:"start_date(2i)"].to_i,params[:check_run_filter][:"start_date(3i)"].to_i)
      end_date = Date.civil(params[:check_run_filter][:"wnd_date(1i)"].to_i,params[:check_run_filter][:"end_date(2i)"].to_i,params[:check_run_filter][:"end_date(3i)"].to_i)
      @check_run_filter = CheckRunFilter.new({:start_date => start_date, :end_date=> end_date})
    end
    
    if !params[:check_run_filter] || !@check_run_filter.valid?
      if first_check_run = @health_check.check_runs.first
        @check_run_filter = CheckRunFilter.new(:start_date => first_check_run.created_at, :end_date => (DateTime.now + 1.day))
      else
        @check_run_filter = CheckRunFilter.new
      end
    end
  end
end
