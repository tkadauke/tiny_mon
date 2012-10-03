class HealthChecksController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  active_tab :health_checks
  
  def index
    @report = if params[:report]
      current_user.soft_settings.set("health_checks.report", params[:report])
    else
      current_user.soft_settings.get("health_checks.report", :default => 'details')
    end
    
    @status = if params[:status]
      current_user.soft_settings.set("health_checks.status", params[:status])
    else
      current_user.soft_settings.get("health_checks.status", :default => 'all')
    end
    
    @search_filter = SearchFilter.new(params[:search_filter])
    if @site
      @health_checks = @site.health_checks.filter_for_list(@search_filter, params[:status]).order('health_checks.name ASC')
    else
      @health_checks = @account.health_checks.filter_for_list(@search_filter, params[:status]).order('sites.name ASC, health_checks.name ASC')
      render 'all_checks' unless request.xhr?
    end
  end
  
  def new
    can_create_health_checks!(@account) do
      find_templates
      @health_check = @site.health_checks.build
    end
  end
  
  def create
    can_create_health_checks!(@account) do
      @health_check_template = HealthCheckTemplate.find_by_id(params[:template])
      @health_check = @site.health_checks.build(params[:health_check].merge(:template => @health_check_template))
      if params[:commit] == I18n.t("health_checks.template_form.preview")
        @health_check.get_info_from_template
        @preview = true
        render :action => 'new'
      else
        if @health_check.save
          flash[:notice] = I18n.t('flash.notice.created_health_check', :health_check => @health_check.name)
          redirect_to account_site_health_check_steps_path(@account, @site, @health_check)
        else
          render :action => 'new'
        end
      end
    end
  end
  
  def show
    @health_check = @site.health_checks.find_by_permalink!(params[:id])
    @comments = @health_check.latest_comments.limit(5)
    @comments_count = @health_check.comments.count
  end
  
  def edit
    can_edit_health_checks!(@account) do
      @health_check = @site.health_checks.find_by_permalink!(params[:id])
    end
  end
  
  def edit_multiple
    redirect_to :back and return if params[:health_check_ids].blank?
    
    can_edit_health_checks!(@account) do
      @health_checks = @account.health_checks.order('sites.name ASC, health_checks.name ASC').includes(:site).find(params[:health_check_ids])
    end
  end
  
  def update
    can_edit_health_checks!(@account) do
      @health_check = @site.health_checks.find_by_permalink!(params[:id])
      if @health_check.update_attributes(params[:health_check])
        flash[:notice] = I18n.t('flash.notice.updated_health_check', :health_check => @health_check.name)
        redirect_to account_site_health_check_path(@account, @site, @health_check)
      else
        render :action => 'edit'
      end
    end
  end
  
  def update_multiple
    can_edit_health_checks!(@account) do
      @health_checks = @account.health_checks.find(params[:health_check_ids])
      updated = @health_checks.map do |health_check|
        health_check.bulk_update(params[:health_check])
      end
      
      flash[:notice] = I18n.t("flash.notice.bulk_updated_health_checks", :count => updated.count(true))
      redirect_to health_checks_path
    end
  end
  
  def destroy
    can_delete_health_checks!(@account) do
      @health_check = @site.health_checks.find_by_permalink!(params[:id])
      @health_check.destroy
      flash[:notice] = I18n.t('flash.notice.deleted_health_check', :health_check => @health_check.name)
      redirect_to account_site_health_checks_path(@account, @site)
    end
  end
  
protected
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id]) if params[:site_id]
  end
  
  def find_templates
    @health_check_template = HealthCheckTemplate.find_by_id(params[:template])
    if !@health_check_template
      scope = case params[:filter]
      when 'mine'
        current_user.health_check_templates
      when 'account'
        @account.health_check_templates
      when 'public'
        HealthCheckTemplate.public_templates
      else
        current_user.available_health_check_templates
      end
      
      @health_check_templates = scope.order('name ASC').paginate(:page => params[:page])
    end
  end
end
