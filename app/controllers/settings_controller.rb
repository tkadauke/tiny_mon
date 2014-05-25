class SettingsController < ApplicationController
  before_filter :login_required
  before_filter :can_edit_settings!
  
  def show
    # @config does not work. See
    # http://rails.lighthouseapp.com/projects/8994/tickets/5342-rails-300rc-does-not-allow-config-instance-variable-in-controllers
    @configuration = current_user.config
    @page_title = t('.settings')
  end
  
  def create
    current_user.config.update_attributes(params[:configuration])
    flash[:notice] = I18n.t('flash.notice.updated_settings')
    redirect_to settings_path
  end
end
