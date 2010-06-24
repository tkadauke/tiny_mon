class SitesController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  
  def index
    @sites = @account.sites.find(:all, :order => 'name ASC')
  end
  
  def new
    @site = @account.sites.build
  end
  
  def create
    @site = @account.sites.build(params[:site])
    if @site.save
      flash[:notice] = I18n.t('flash.notice.created_site', :site => @site.name)
      redirect_to site_health_checks_path(@site)
    else
      render :action => 'new'
    end
  end
  
  def show
    @site = @account.sites.find_by_permalink!(params[:id])
    redirect_to site_health_checks_path(@site)
  end
  
  def edit
    @site = @account.sites.find_by_permalink!(params[:id])
  end
  
  def update
    @site = @account.sites.find_by_permalink!(params[:id])
    if @site.update_attributes(params[:site])
      flash[:notice] = I18n.t('flash.notice.updated_site', :site => @site.name)
      redirect_to site_path(@site)
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

protected
  def find_account
    @account = current_user.current_account
  end
end
