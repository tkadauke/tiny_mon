module CheckRunsHelper
  def format_log_message(message)
    case message
    when /<html/
      format_embedded_html_page(message)
    else
      content_tag(:code) { auto_link(message).html_safe }
    end
  end
  
  def format_embedded_html_page(message)
    id = "msg#{message.object_id}"
    html = "<div style='width: 100%; height: 300px; overflow: scroll; -webkit-overflow-scrolling: touch'>"
    html << "<iframe id='#{id}' width='100%' height='300px'></iframe>"
    html << "</div>"
    html << javascript_tag("var doc=$('##{id}')[0].contentDocument;doc.open(); doc.write('#{escape_javascript(message)}');doc.close()")
    
    html.html_safe
  end
end
