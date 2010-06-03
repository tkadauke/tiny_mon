class CheckContentStep < Step
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  
  def run!(session)
    session.log "Checking content for #{content}"
    
    utf8_body = if session.response.encoding.nil? || ['utf-8', 'utf8'].include?(session.response.encoding.downcase)
      session.response.body
    else
      Iconv.conv('UTF-8//TRANSLIT', session.response.encoding, session.response.body)
    end
    
    unless utf8_body =~ Regexp.new(Regexp.escape(content))
      session.log utf8_body
      session.fail ContentCheckFailed, "Expected page to contain #{content}"
    end
  end
end
