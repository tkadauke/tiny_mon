class SettingsController < ApplicationController
  before_filter :login_required
  before_filter :can_edit_settings!
  
  def show
    @config = current_user.config
  end
  
  def create
    current_user.config.update_attributes(params[:config])
    flash[:notice] = I18n.t('flash.notice.updated_settings')
    redirect_to settings_path
  end
end
