class HealthCheckImportsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site

  before_filter :check_account_permissions
  
  before_filter :find_health_check_template, :only => [ :new ]
  
  def index
    @health_check_imports = @site.health_check_imports
  end
  
  def new
    @health_check_import = HealthCheckImport.new(:health_check_template => @health_check_template)
  end
  
  def create
    @health_check_import = HealthCheckImport.new(params[:health_check_import])
    if params[:commit] == I18n.t("health_check_imports.new.preview")
      @preview = true
      render :action => 'new'
    else
      @health_check_import.user = current_user
      @health_check_import.account = @account
      @health_check_import.site = @site
      
      if @health_check_import.save
        flash[:notice] = I18n.t("flash.notice.created_import")
        redirect_to account_site_health_checks_path(@account, @site)
      else
        render :action => 'new'
      end
    end
  end
  
  def destroy
    @health_check_import = HealthCheckImport.find(params[:id])
    can_delete_health_check_imports!(@health_check_import.account) do
      @health_check_import.destroy
      flash[:notice] = I18n.t("flash.notice.deleted_import")
      redirect_to account_site_health_check_imports_path(@account, @site)
    end
  end
  
protected
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id])
  end
  
  def find_health_check_template
    @health_check_template = HealthCheckTemplate.find(params[:template])
  end

  def check_account_permissions
    deny_access unless current_user.can_create_health_check_imports?(current_user.current_account)
  end
end
