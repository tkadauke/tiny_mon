# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :set_language
  before_filter :set_locale
  
  helper_method :current_user_session, :current_user, :logged_in?

protected
  def method_missing(method, *args)
    if method.to_s =~ /^can_.*\?$/
      if current_user.send(method, *args)
        yield if block_given?
        true
      else
        false
      end
    elsif method.to_s =~ /^can_.*\!$/
      if current_user.send(method.to_s.gsub(/\!$/, '?'), *args)
        yield if block_given?
      else
        deny_access
        false
      end
    else
      super
    end
  end
  
  def default_url_options(options={})
    { :locale => I18n.locale }
  end
  
  def set_language
    return if params[:locale]
    
    if logged_in?
      redirect_to :locale => current_user.config.language
    else
      redirect_to :locale => TinyMon::Config.language if TinyMon::Config.language
    end
  end
  
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  def login_required
    deny_access(I18n.t("flash.error.login_required"), login_path) unless current_user
  end

  def guest_required
    deny_access(I18n.t("flash.error.guest_required")) if current_user
  end
  
  def deny_access(message = nil, path = root_path)
    store_location
    flash[:error] = message || I18n.t("flash.error.access_denied")
    
    respond_to do |wants|
      wants.html { redirect_to path }
      wants.json { render :json => {}, :status => :unauthorized }
    end
    
    return false
  end
  
  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def logged_in?
    !current_user.nil?
  end

  def find_account
    @account = params[:account_id] ? Account.find(params[:account_id]) : current_user.current_account
    if @account
      can_see_account!(@account) do
        if current_user.current_account != @account
          flash[:notice] = I18n.t('flash.notice.switched_account', :account => @account.name)
          current_user.switch_to_account(@account)
        end
      end
    else
      flash[:error] = I18n.t("flash.error.create_account_first")
      redirect_to new_account_path
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

private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
end
