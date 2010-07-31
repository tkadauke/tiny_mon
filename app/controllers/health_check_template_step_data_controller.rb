class HealthCheckTemplateStepDataController < ApplicationController
  def new
    render :partial => 'step_data_form', :locals => { :step_index => params[:step_index], :step_type => params[:step_type] }
  end
end
