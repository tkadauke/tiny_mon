class SitesController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  
  def index
    @sites = @account.sites.find(:all, :include => :account, :order => 'name ASC')
  end
  
  def new
    @site = @account.sites.build
  end
  
  def create
    @site = @account.sites.build(params[:site])
    if @site.save
      flash[:notice] = I18n.t('flash.notice.created_site', :site => @site.name)
      redirect_to account_site_health_checks_path(@account, @site)
    else
      render :action => 'new'
    end
  end
  
  def show
    @site = @account.sites.find_by_permalink!(params[:id])
    redirect_to account_site_health_checks_path(@account, @site)
  end
  
  def edit
    @site = @account.sites.find_by_permalink!(params[:id])
  end
  
  def update
    @site = @account.sites.find_by_permalink!(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = I18n.t('flash.notice.updated_site', :site => @site.name)
      redirect_to account_site_path(@account, @site)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @site = @account.sites.find_by_permalink!(params[:id])
    @site.destroy
    flash[:notice] = I18n.t('flash.notice.deleted_site', :site => @site.name)
    redirect_to sites_path
  end
end
