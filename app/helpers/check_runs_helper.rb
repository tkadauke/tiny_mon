module CheckRunsHelper
  def format_log_message(message)
    case message
    when /<html/
      format_embedded_html_page(message)
    else
      content_tag(:code) { auto_link(message) }
    end
  end
  
  def format_embedded_html_page(message)
    id = "msg#{message.object_id}"
    html = "<iframe id=#{id}></iframe>"
    html << javascript_tag("var doc=$('#{id}').contentDocument;doc.open(); doc.write('#{escape_javascript(message)}');doc.close()")
    html
  end
end
