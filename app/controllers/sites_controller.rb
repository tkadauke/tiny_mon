class SitesController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  active_tab :sites
  
  respond_to :html, :json, :xml, :js
  
  def index
    @search_filter = SearchFilter.new(params[:search_filter])
    @sites = @account.sites.find_for_list(@search_filter)
    respond_with @sites
  end
  
  def new
    can_create_sites!(@account) do
      @site = @account.sites.new
      respond_with @site
    end
  end
  
  def create
    can_create_sites!(@account) do
      @site = @account.sites.new(site_params)
      if @site.save
        flash[:notice] = I18n.t('flash.notice.created_site', :site => @site.name)
      end
      respond_with @site, :location => account_site_health_checks_path(@account, @site)
    end
  end
  
  def show
    @site = @account.sites.find_by_permalink!(params[:id])
    respond_with @site
  end
  
  def edit
    can_edit_sites!(@account) do
      @site = @account.sites.find_by_permalink!(params[:id])
      respond_with @site
    end
  end
  
  def update
    can_edit_sites!(@account) do
      @site = @account.sites.find_by_permalink!(params[:id])
      if @site.update_attributes(site_params)
        flash[:notice] = I18n.t('flash.notice.updated_site', :site => @site.name)
      end
      respond_with @site, :location => account_site_path(@account, @site)
    end
  end
  
  def destroy
    can_delete_sites!(@account) do
      @site = @account.sites.find_by_permalink!(params[:id])
      @site.destroy
      flash[:notice] = I18n.t('flash.notice.deleted_site', :site => @site.name)
      respond_with @site, :location => sites_path
    end
  end

private
  def site_params
    params.require(:site).permit :name, :url, :slack_enabled, :slack_team, :slack_token
  end
end
