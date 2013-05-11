class CheckContentStep < Step
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  
  validates_presence_of :content
  
  def run!(session, check_run)
    session.log "Checking content for #{content}"
    
    response_body = session.driver.body
    
    unless response_body =~ Regexp.new(Regexp.escape(content))
      session.fail ContentCheckFailed, "Expected page to contain #{content}"
    end
  end
end
