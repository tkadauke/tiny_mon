class HealthChecksController < ApplicationController
  before_filter :find_site
  
  def index
    @health_checks = @site.health_checks
  end
  
  def new
    @health_check = HealthCheck.new
  end
  
  def create
    @health_check = @site.health_checks.build(params[:health_check])
    if @health_check.save
      redirect_to site_health_check_path(@site, @health_check)
    else
      render :action => 'new'
    end
  end
  
  def show
    @health_check = @site.health_checks.find(params[:id])
  end
  
  def edit
    @health_check = @site.health_checks.find(params[:id])
  end
  
  def update
    @health_check = @site.health_checks.find(params[:id])
    if @health_check.update_attributes(params[:health_check])
      redirect_to site_health_check_path(@site, @health_check)
    else
      render :action => 'edit'
    end
  end
  
protected
  def find_site
    @site = Site.find(params[:site_id])
  end
end
