# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def auto_update(container)
    periodically_call_remote(:url => request.request_uri, :update => container, :method => 'get', :frequency => '10')
  end

  def bread_crumb
    breadcrumb = %{<a href="/">#{I18n.t('breadcrumb.home')}</a>}
    sofar = ''
    elements = request.request_uri.split('?').first.split('/')
    parent_model = nil
    for i in 1...elements.size
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
        
      breadcrumb += ' &gt; '
      if sofar == request.path
        breadcrumb += "<strong>"  + link_text + '</strong>'
      else
        breadcrumb += "<a href='#{sofar}'>"  + link_text + '</a>'
      end
    end
    breadcrumb
  end
  
  def status_icon(model, version = :small)
    return if model.blank? || model.status.blank?
    
    status = model.status
    status = 'offline' if model.respond_to?(:enabled?) && !model.enabled?
    
    image_tag "icons/#{version}/#{status}.png", :alt => t("status.#{status}"), :title => t("status.#{status}")
  end
  
  def overall_status
    if current_user.current_account.all_checks_successful?
      image_tag "icons/large/success.png", :alt => I18n.t("status.all_checks_successful"), :title => I18n.t("status.all_checks_successful")
    else
      image_tag "icons/large/failure.png", :alt => I18n.t("status.one_or_more_checks_failed"), :title => I18n.t("status.one_or_more_checks_failed")
    end
  end
  
  def revision_link
    build = TinyMon::Version.build
    if build == 'unknown'
      I18n.t('layouts.unknown_build')
    else
      link_to(build[0..7], "http://github.com/tkadauke/tiny_mon/commit/#{TinyMon::Version.build}")
    end
  end
end
