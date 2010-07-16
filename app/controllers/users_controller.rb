class UsersController < ApplicationController
  before_filter :login_required, :only => [:index, :show, :edit, :update]
  
  def index
    redirect_to account_path(current_user.current_account)
  end
  
  def new
    @user = User.new
  end
  
  def create
    if logged_in?
      @user = current_user.current_account.users.build(params[:user])
      @user.current_account = current_user.current_account
    else
      @user = User.new(params[:user])
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
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('flash.notice.updated_user')
      redirect_to root_path
    else
      render :action => :edit
    end
  end
end
