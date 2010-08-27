# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def auto_update(container)
    periodically_call_remote(:url => request.request_uri, :update => container, :method => 'get', :frequency => '10')
  end

  def status_icon(model, version = :small)
    return if model.blank? || model.status.blank?
    
    status = model.status
    status = 'offline' if model.respond_to?(:enabled?) && !model.enabled?
    
    image_tag "icons/#{version}/#{status}.png", :alt => t("status.#{status}"), :title => t("status.#{status}")
  end
  
  def overall_status(model = current_user.current_account, version = :large)
    if model.all_checks_successful?
      image_tag "icons/#{version}/success.png", :alt => I18n.t("status.all_checks_successful"), :title => I18n.t("status.all_checks_successful")
    else
      image_tag "icons/#{version}/failure.png", :alt => I18n.t("status.one_or_more_checks_failed"), :title => I18n.t("status.one_or_more_checks_failed")
    end
  end
  
  def weather_icon(model, version = :small)
    return if model.blank? || model.weather.blank?
    
    image_tag "icons/#{version}/weather-#{model.weather}.png", :alt => I18n.t("weather.count_successful", :count => model.weather), :title => I18n.t("weather.count_successful", :count => model.weather)
  end
  
  def revision_link
    build = TinyMon::Version.build
    if build == 'unknown'
      I18n.t('layouts.unknown_build')
    else
      link_to(build[0..7], "http://github.com/tkadauke/tiny_mon/commit/#{TinyMon::Version.build}")
    end
  end
  
  def show_help?
    current_user.soft_settings.get("help.show", :default => '1') == '1'
  end
  
  def current_tutorial
    @current_tutorial ||= current_user.soft_settings.get("tutorials.current")
  end
  
  def help
    return unless logged_in? && show_help?
    
    if current_tutorial
      render :partial => "/tutorials/tutorial"
    else
      begin
        render :partial => "/shared/help"
      rescue
      end
    end
  end
  
  def warning_tag(notice, url)
    content_tag(:div, :class => 'warning') { [notice, link_to(I18n.t("warning.more_info"), url)].join(' ') }
  end
  
  def account_check_run_limit_warning_if_needed
    account = current_user.current_account
    notice = if account.over_maximum_check_runs_per_day? && account.over_maximum_check_runs_today?
      I18n.t("warning.over_max_check_runs_per_day_and_today", :maximum => account.maximum_check_runs_per_day)
    elsif account.over_maximum_check_runs_per_day?
      I18n.t("warning.over_max_check_runs_per_day", :maximum => account.maximum_check_runs_per_day)
    elsif account.over_maximum_check_runs_today?
      I18n.t("warning.over_max_check_runs_today", :maximum => account.maximum_check_runs_per_day)
    end
    
    warning_tag notice, 'http://tinymon.org/pages/support' if notice
  end
  
  def partial_route(route, *params)
    lambda do |new_options|
      new_params = params.dup
      options = new_params.extract_options!
      send(route, *(new_params << options.merge(new_options)))
    end
  end
end
