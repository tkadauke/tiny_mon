# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include TinyCore::Controllers::Application
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :set_language

protected
  def set_language
    if logged_in?
      I18n.locale = current_user.config.language
    else
      I18n.locale = TinyCore::Config.language if TinyCore::Config.language
    end
  end

  def render_optional_error_file(status_code)
    activate_authlogic
    set_language
    
    status = interpret_status(status_code)
    render :template => "/errors/#{status[0,3]}.html.erb", :status => status, :layout => 'plain'
  end
  
  def self.active_tab(tab, options = {})
    before_filter options do |controller|
      controller.instance_variable_set(:@tab, tab)
    end
  end
end
