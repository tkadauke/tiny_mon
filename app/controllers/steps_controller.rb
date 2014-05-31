class StepsController < ApplicationController
  before_filter :login_required
  before_filter :find_account
  before_filter :find_site
  before_filter :find_health_check
  active_tab :health_checks
  
  skip_before_filter :verify_authenticity_token, :only => :sort
  
  respond_to :html, :xml, :json, :js
  
  def index
    respond_with @steps = @health_check.steps
  end

  def new
    can_edit_health_checks!(@account) do
      if params[:clone]
        @steps = @health_check.steps_with_clone(params[:clone])
        render :action => 'index'
      else
        @step = "#{params[:type]}_step".classify.constantize.new
        render :partial => '/steps/form', :locals => { :step => @step } if request.xhr?
      end
    end
  end
  
  def edit
    can_edit_health_checks!(@account) do
      respond_with @step = @health_check.steps.find(params[:id])
    end
  end
  
  def create
    can_edit_health_checks!(@account) do
      type_name = "#{params[:type]}_step"
      @step = type_name.classify.constantize.new(step_params)
      @step.health_check = @health_check
      if @step.save
        respond_with @step, :location => account_site_health_check_steps_path(@account, @site, @health_check)
      else
        @steps = @health_check.steps
        render :action => 'index'
      end
    end
  end
  
  def update
    can_edit_health_checks!(@account) do
      @step = @health_check.steps.find(params[:id])
      @step.update_attributes(step_update_params(@step.type))
      respond_with @step, :location => account_site_health_check_steps_path(@account, @site, @health_check) do |format|
        format.html { redirect_to :back }
      end
    end
  end
  
  def destroy
    can_edit_health_checks!(@account) do
      @step = @health_check.steps.find(params[:id])
      @step.destroy
      respond_with @step do |format|
        format.html { redirect_to :back }
      end
    end
  end
  
  def sort
    can_edit_health_checks!(@account) do
      params[:step].each_with_index do |id, i|
        @health_check.steps.find(id).update_attribute(:position, i)
      end
      render :nothing => true
    end
  end

protected
  def step_params
    klass = "#{params[:type]}_step".classify.constantize
    params.require(klass.name.underscore).permit(klass.properties.keys)
  end

  def step_update_params(type)
    klass = type.constantize
    params.require(klass.name.underscore).permit([:id] + klass.properties.keys)
  end

  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id])
  end

  def find_health_check
    @health_check = @site.health_checks.find_by_permalink!(params[:health_check_id])
  end
end
