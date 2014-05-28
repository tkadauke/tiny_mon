class HealthCheckTemplatesController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :check_account_permissions
  
  def index
    @health_check_templates = current_user.health_check_templates.order('name ASC')
    @page_title = t(".my_templates")
  end
  
  def new
    @health_check_template = HealthCheckTemplate.new
    @health_check_template.variables.build
    @health_check_template.steps.build
    @page_title = t(".new_template")
  end
  
  def edit
    @health_check_template = HealthCheckTemplate.find(params[:id])
    can_edit_health_check_template!(@health_check_template)
  end
  
  def create
    @health_check_template = HealthCheckTemplate.new(health_check_params)
    @health_check_template.user = current_user
    @health_check_template.account = current_user.current_account
    if @health_check_template.save
      flash[:notice] = I18n.t("flash.notice.created_health_check_template")
      redirect_to health_check_templates_path
    else
      render :action => 'new'
    end
  end
  
  def update
    @health_check_template = HealthCheckTemplate.find(params[:id])
    can_edit_health_check_template!(@health_check_template) do
      if @health_check_template.update_attributes(health_check_params)
        flash[:notice] = I18n.t("flash.notice.updated_health_check_template")
        redirect_to health_check_templates_path
      else
        render :action => 'new'
      end
    end
  end
  
  def destroy
    @health_check_template = HealthCheckTemplate.find(params[:id])
    can_delete_health_check_template!(@health_check_template) do
      @health_check_template.destroy
      flash[:notice] = I18n.t("flash.notice.deleted_health_check_template")
      redirect_to health_check_templates_path
    end
  end

protected
  def health_check_params
    params.require(:health_check_template).permit!
  end
  def check_account_permissions
    deny_access unless current_user.can_create_health_check_templates?(@account)
  end
end
