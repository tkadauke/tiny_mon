class HealthCheckTemplateVariablesController < ApplicationController
  def new
    child_index = params[:sequence]
    render :update do |page|
      page.replace 'replace-variable', :partial => 'variable_form', :locals => { :child_index => child_index }
    end
  end
end
