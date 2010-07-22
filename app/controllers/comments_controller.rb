class CommentsController < ApplicationController
  before_filter :login_required
  before_filter :find_parent_models, :only => :index
  before_filter :find_check_run_parent_models, :only => [ :new, :create ]
  
  def index
    if @check_run
      @comments = @check_run.comments
      @comment = Comment.new
    elsif @health_check
      @comments = @health_check.comments
    elsif @user
      @comments = @user.comments
    else
      raise ActiveRecord::RecordNotFound
    end
  end
  
  def new
    can_create_comments!(@account) do
      @comment = @check_run.comments.build(params[:comment])
    end
  end
  
  def create
    can_create_comments!(@account) do
      @comment = @check_run.comments.create(params[:comment])
      @comment.user = current_user
      if @comment.save
        flash[:notice] = I18n.t("flash.notice.created_comment")
        redirect_to account_site_health_check_check_run_path(@account, @site, @health_check, @check_run)
      else
        render :action => 'new'
      end
    end
  end
  
protected
  def find_parent_models
    if params[:user_id]
      find_user
    else
      find_check_run_parent_models
    end
  end
  
  def find_check_run_parent_models
    find_account
    find_site
    find_health_check
    find_check_run
  end
  
  def find_user
    @user = User.from_param!(params[:user_id])
  end
  
  def find_site
    @site = @account.sites.find_by_permalink!(params[:site_id])
  end

  def find_health_check
    @health_check = @site.health_checks.find_by_permalink!(params[:health_check_id])
  end
  
  def find_check_run
    @check_run = @health_check.check_runs.find_by_id(params[:check_run_id])
  end
end
