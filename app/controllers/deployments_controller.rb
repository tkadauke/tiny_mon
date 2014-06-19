class DeploymentsController < ApplicationController
  before_filter :login_required, :except => :create
  before_filter :find_site_by_token_or_login_required, :only => :create
  before_filter :find_account, :except => :create
  before_filter :find_site, :except => :create
  active_tab :sites
  
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def index
    @deployments = @site.deployments.order('created_at DESC').paginate(:page => params[:page])
  end
  
  def new
    can_create_deployments!(@account) do
      @deployment = @site.deployments.build
    end
  end
  
  def show
    @deployment = @site.deployments.find(params[:id])
    @check_runs = @deployment.check_runs.order('created_at DESC').paginate(:page => params[:page])
  end
  
  def create
    @deployment = @site.deployments.build(deployment_params)
    if @deployment.save
      @deployment.schedule_checks!
      flash[:notice] = I18n.t("flash.notice.created_deployment")
      redirect_to account_site_deployments_path(@account, @site)
    else
      render :action => 'new'
    end
  end

protected
  def find_site_by_token_or_login_required
    if params[:token].blank?
      [:verify_authenticity_token, :login_required, :find_account, :find_site, :check_permissions].each do |filter|
        return false if send(filter) == false
      end
    else
      @site = Site.find_by_deployment_token(params[:token])
      @account = @site.account
    end
  end
  
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id])
  end
  
  def check_permissions
    can_create_deployments!(@account)
  end

  def deployment_params
    params.require(:deployment).permit(:revision, :schedule_checks_in)
  end
end
