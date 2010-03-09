class CheckContentStep < Step
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  
  def run!(session)
    session.log "Checking content for #{content}"
    unless session.response.body =~ Regexp.new(Regexp.escape(content))
      session.log session.response.body
      session.fail ContentCheckFailed, "Expected page to contain #{content}"
    end
  end
end
