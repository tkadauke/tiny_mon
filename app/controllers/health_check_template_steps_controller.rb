class HealthCheckTemplateStepsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :check_account_permissions
  
  def new
    @child_index = params[:sequence]
  end

protected
  def check_account_permissions
    deny_access unless current_user.can_create_health_check_templates?(@account)
  end
end
