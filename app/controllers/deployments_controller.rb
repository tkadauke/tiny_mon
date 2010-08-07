class DeploymentsController < ApplicationController
  before_filter :login_required, :except => :create
  before_filter :find_site_by_token_or_login_required, :only => :create
  before_filter :find_account, :except => :create
  before_filter :find_site, :except => :create
  
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def index
    @deployments = @site.deployments.paginate(:order => 'created_at DESC', :page => params[:page])
  end
  
  def new
    can_create_deployments!(@account) do
      @deployment = @site.deployments.build
    end
  end
  
  def show
    @deployment = @site.deployments.find(params[:id])
    @check_runs = @deployment.check_runs.paginate(:order => 'created_at DESC', :page => params[:page])
  end
  
  def create
    @deployment = @site.deployments.build(params[:deployment])
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
      [:verify_authenticity_token, :login_required, :find_account, :find_site, :can_create_deployments!].each do |filter|
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
end
