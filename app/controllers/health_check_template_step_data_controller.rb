class HealthCheckTemplateStepDataController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :check_account_permissions
  
  def new
    render :partial => 'step_data_form', :locals => { :step_index => params[:step_index], :step_type => params[:step_type] }
  end

protected
  def check_account_permissions
    can_create_health_check_templates!(@account)
  end
end
