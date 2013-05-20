require 'iconv'

class CheckContentStep < Step
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  property :negate, :boolean
  
  validates_presence_of :content
  
  def run!(session, check_run)
    session.log "Checking content for #{content}"
    
    utf8_body = if session.response.encoding.nil? || ['utf-8', 'utf8'].include?(session.response.encoding.downcase)
      session.response.body
    else
      Iconv.conv('UTF-8//TRANSLIT', session.response.encoding, session.response.body)
    end
    
    rx = Regexp.new(Regexp.escape(content))
    
    if negate
      unless utf8_body !~ rx
        session.log utf8_body
        session.fail ContentCheckFailed, "Expected page to not contain #{content}"
      end
    else
      unless utf8_body =~ rx
        session.log utf8_body
        session.fail ContentCheckFailed, "Expected page to contain #{content}"
      end
    end
  end
end
