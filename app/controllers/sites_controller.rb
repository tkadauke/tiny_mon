class SitesController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  active_tab :sites
  
  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @sites = @account.sites.find_for_list(@search_filter)
  end
  
  def new
    can_create_sites!(@account) do
      @site = @account.sites.build
    end
  end
  
  def create
    can_create_sites!(@account) do
      @site = @account.sites.build(params[:site])
      if @site.save
        flash[:notice] = I18n.t('flash.notice.created_site', :site => @site.name)
        redirect_to account_site_health_checks_path(@account, @site)
      else
        render :action => 'new'
      end
    end
  end
  
  def show
    @site = @account.sites.find_by_permalink!(params[:id])
  end
  
  def edit
    can_edit_sites!(@account) do
      @site = @account.sites.find_by_permalink!(params[:id])
    end
  end
  
  def update
    can_edit_sites!(@account) do
      @site = @account.sites.find_by_permalink!(params[:id])
      if @site.update_attributes(params[:site])
        flash[:notice] = I18n.t('flash.notice.updated_site', :site => @site.name)
        redirect_to account_site_path(@account, @site)
      else
        render :action => 'edit'
      end
    end
  end
  
  def destroy
    can_delete_sites!(@account) do
      @site = @account.sites.find_by_permalink!(params[:id])
      @site.destroy
      flash[:notice] = I18n.t('flash.notice.deleted_site', :site => @site.name)
      redirect_to sites_path
    end
  end
end
