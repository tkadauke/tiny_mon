class CheckRunsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  before_filter :find_health_check
  
  def index
    @check_runs = @health_check.recent_check_runs.find :all, :include => :health_check
    respond_to do |format|
      format.html { render :partial => "/check_runs/activity" if request.xhr? }
      format.png { send_data(CheckRunGraph.new(@check_runs.reverse).render, :disposition => 'inline', :type => 'image/png', :filename => "check_runs.png") }
    end
  end
  
  def show
    @check_run = @health_check.check_runs.find(params[:id])
    @comment = @check_run.comments.build
    @comments = @check_run.latest_comments
    @comments_count = @check_run.comments.count
  end
  
  def create
    can_run_health_checks!(@account) do
      @check_run = @health_check.check!
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
end
