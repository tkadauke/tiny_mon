# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def gravatar(user, options = {})
    hash = Digest::MD5.hexdigest(user.email.strip.downcase)
    link_to image_tag("http://www.gravatar.com/avatar/#{hash}.png?s=#{options[:size] || 20}"), user_path(user)
  end
  
  def auto_update(container)
    # periodically_call_remote(:url => request.request_uri, :update => container, :method => 'get', :frequency => '10')
  end

  def bread_crumb
    items = [%{<a href="/">#{I18n.t('breadcrumb.home')}</a>}]
    sofar = ''
    elements = request.fullpath.split('?').first.split('/')
    parent_model = nil
    for i in 2...elements.size
      sofar += '/' + elements[i]
      
      parent_model, link_text = begin
        next_model = if parent_model
          parent_model.instance_eval("#{elements[i - 1]}.from_param!('#{elements[i]}')")
        else
          eval("#{elements[i - 1].singularize.camelize}.from_param!('#{elements[i]}')")
        end
        [next_model, next_model.respond_to?(:name) ? next_model.name : next_model.to_param]
      rescue Exception => e
        [parent_model, I18n.t("breadcrumb.#{elements[i]}")]
      end
        
      if sofar == request.path
        items << "<strong>"  + link_text + '</strong>'
      else
        items << "<a href='#{sofar}'>"  + link_text + '</a>'
      end
    end
    
    content_tag :ul do
      items.collect { |item| content_tag(:li) { item.html_safe } }.join.html_safe
    end
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
