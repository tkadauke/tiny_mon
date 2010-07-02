class SettingsController < ApplicationController
  def show
    @config = current_user.config
  end
  
  def create
    current_user.config.update_attributes(params[:config])
    flash[:notice] = I18n.t('flash.notice.updated_settings')
    redirect_to settings_path
  end
end
