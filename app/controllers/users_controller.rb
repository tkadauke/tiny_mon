class UsersController < ApplicationController
  before_filter :login_required, :only => [:show, :edit, :update]
  
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
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = I18n.t('flash.notice.updated_user')
      redirect_to root_path
    else
      render :action => :edit
    end
  end
end
