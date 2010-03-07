class CheckRunsController < ApplicationController
  before_filter :find_site
  before_filter :find_health_check
  
  def index
    @check_runs = @health_check.recent_check_runs
    respond_to do |format|
      format.html
      format.png { send_data(CheckRunGraph.new(@check_runs).render, :disposition => 'inline', :type => 'image/png', :filename => "check_runs.png") }
    end
  end
  
  def show
    @check_run = @health_check.check_runs.find(params[:id])
  end
  
protected
  def find_site
    @site = Site.find_by_permalink!(params[:site_id])
  end

  def find_health_check
    @health_check = @site.health_checks.find_by_permalink!(params[:health_check_id])
  end
end
