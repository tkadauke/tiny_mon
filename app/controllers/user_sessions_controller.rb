class UserSessionsController < ApplicationController
  before_filter :guest_required, :only => [ :new ]
  skip_before_filter :verify_authenticity_token, :only => :create

  respond_to :html, :xml, :json

  def new
    @user_session = UserSession.new
    respond_with @user_session
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = I18n.t("flash.notice.logged_in")
    end
    
    respond_with @user_session, :location => root_path
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = I18n.t("flash.notice.logged_out")
    respond_with current_user_session, :location => login_path
  end
end
