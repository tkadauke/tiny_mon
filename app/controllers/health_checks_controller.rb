class HealthChecksController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  
  def index
    if @site
      @health_checks = @site.health_checks.find(:all, :include => { :site => :account }, :order => 'health_checks.name ASC')
    else
      @health_checks = @account.health_checks.find(:all, :include => { :site => :account }, :order => 'sites.name ASC, health_checks.name ASC')
      render :action => 'all_checks' unless request.xhr?
    end
    render :partial => 'list' if request.xhr?
  end
  
  def new
    @health_check = @site.health_checks.build
  end
  
  def create
    @health_check = @site.health_checks.build(params[:health_check])
    if @health_check.save
      flash[:notice] = I18n.t('flash.notice.created_health_check', :health_check => @health_check.name)
      redirect_to account_site_health_check_path(@account, @site, @health_check)
    else
      render :action => 'new'
    end
  end
  
  def show
    @health_check = @site.health_checks.find_by_permalink!(params[:id])
  end
  
  def edit
    @health_check = @site.health_checks.find_by_permalink!(params[:id])
  end
  
  def update
    @health_check = @site.health_checks.find_by_permalink!(params[:id])
    if @health_check.update_attributes(params[:health_check])
      flash[:notice] = I18n.t('flash.notice.updated_health_check', :health_check => @health_check.name)
      redirect_to account_site_health_check_path(@account, @site, @health_check)
    else
      render :action => 'edit'
    end
  end
  
protected
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id]) if params[:site_id]
  end
end
