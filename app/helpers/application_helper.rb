# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def auto_update(container)
    periodically_call_remote(:url => request.request_uri, :update => container, :method => 'get', :frequency => '60')
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
        [next_model, next_model.to_param]
      rescue Exception => e
        [parent_model, I18n.t("breadcrumb.#{elements[i]}")]
      end
        
      breadcrumb += ' &gt; '
      breadcrumb += "<a href='#{sofar}'>"  + link_text + '</a>'
    end
    breadcrumb
  end
  
  def status_icon(status, version = :small)
    image_tag "icons/#{version}/#{status}.png", :alt => t("status.#{status}"), :title => t("status.#{status}")
  end
end
