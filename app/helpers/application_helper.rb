# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def gravatar(user, options = {})
    hash = Digest::MD5.hexdigest(user.email.strip.downcase)
    text = options[:text] ? "&nbsp;" + options[:text] : ""
    link_to image_tag("http://www.gravatar.com/avatar/#{hash}.png?s=#{options[:size] || 20}") + text.html_safe, user_path(user)
  end
  
  def poll(url, options = {})
    default_options = {
      element: "list",
      interval: 10
    }
    options = default_options.merge(options)
    
    javascript_tag %{
      (function worker() {
        if (typeof(previous) == "undefined") {
          previous = "";
        }

        $.ajax({
          url: '#{url}',
          success: function(data) {
            var btngroups = $('.btn-group.open');
            if (btngroups.length == 0 && data != previous) {
              $('##{options[:element]}').html(data);
              previous = data;
            }
          },
          complete: function() {
            setTimeout(worker, #{options[:interval] * 1000});
          }
        });
      })();
    }
  end

  def bread_crumb
    items = [%{<a href="/#{I18n.locale}">#{I18n.t('breadcrumb.home')}</a>}]
    sofar = "#{I18n.locale}"
    elements = request.fullpath.split('?').first.split('/')
    parent_model = nil
    for i in 2...elements.size
      sofar +=  elements[i]
      
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
    
    items.collect do |item|
      content_tag(:li) do
        [
          item,
          (content_tag(:span, :class => 'divider') { ''} unless item == items.last)
        ].join.html_safe
      end
    end.join.html_safe
  end
  
  def status_icon(model, version = :small)
    return if model.blank? || model.status.blank?
    
    status = model.status
    status = 'offline' if model.respond_to?(:enabled?) && !model.enabled?
    
    image_tag "icons/#{version}/#{status}.png", :alt => t("status.#{status}"), :title => t("status.#{status}")
  end
  
  def status_class(model)
    return if model.blank? || model.status.blank?
    
    if model.status == 'success'
      status = 'success'
    elsif model.status == 'failure'
      status = 'error'
    elsif model.respond_to?(:enabled?) && !model.enabled?
      status = 'warning'
    end
    
    status
  end
  
  def overall_status(model = current_user.current_account, version = :large)
    return if model.nil?
    
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
    content_tag(:div, :class => 'alert alert-warning') { [notice, link_to(I18n.t("warning.more_info"), url)].join(' ').html_safe }
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
