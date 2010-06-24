class UsersController < ApplicationController
  before_filter :guest_required, :only => [:new, :create]
  before_filter :login_required, :only => [:show, :edit, :update]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = I18n.t('flash.notice.created_user')
      redirect_back_or_default root_path
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
