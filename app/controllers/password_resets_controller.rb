class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :guest_required
  
  def index
    render
  end
  
  def new
    render
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = I18n.t("flash.notice.password_instructions_sent")
      redirect_to password_resets_path
    else
      flash[:error] = I18n.t("flash.error.user_by_email_not_found")
      render :action => :new
    end
  end
  
  def edit
    render
  end

  def update
    if @user.reset_password!(params[:user][:password], params[:user][:password_confirmation])
      flash[:notice] = I18n.t("flash.notice.password_updated")
      redirect_to root_path
    else
      render :action => :edit
    end
  end

private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = I18n.t("flash.error.user_could_not_be_located")
      redirect_to login_path
    end
  end
end
