class CheckContentStep < Step
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  
  def run!(session)
    session.log "Checking content for #{content}"
    raise ContentCheckFailed, "Expected page to contain #{content}" unless session.response.body =~ Regexp.new(Regexp.escape(content))
  end
end
