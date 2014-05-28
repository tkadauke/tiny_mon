class UsersController < ApplicationController
  before_filter :login_required, :only => [:index, :show, :edit, :update]
  
  respond_to :html, :xml, :json
  
  def index
    redirect_to account_path(current_user.current_account)
  end
  
  def new
    @user = User.new
  end
  
  def create
    if logged_in?
      @user = current_user.current_account.users.build(user_params)
      @user.current_account = current_user.current_account
    else
      @user = User.new(user_params)
    end
    
    if @user.save
      flash[:notice] = I18n.t('flash.notice.created_user')

      if logged_in?
        @user.accounts << current_user.current_account
        redirect_to new_user_path
      else
        redirect_back_or_default root_path
      end
    else
      render :action => :new
    end
  end
  
  def show
    @user = User.find(params[:id], :include => :accounts)
    can_see_profile!(@user) do
      @comments = @user.latest_comments_for_user(current_user).limit(5)
      @comments_count = @user.comments_count_for_user(current_user)
      respond_with @user, :include => :accounts
    end
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:notice] = I18n.t('flash.notice.updated_user')
      redirect_to root_path
    else
      render :action => :edit
    end
  end

  private
  def user_params
      params.require(:user).permit :full_name, :email, :password, :password_confirmation
  end
end
