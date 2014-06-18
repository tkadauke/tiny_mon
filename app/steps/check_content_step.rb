class CheckContentStep < ScopableStep
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  property :negate, :boolean
  
  validates_presence_of :content

  def run!(session, check_run)
    session.log "Checking content for #{content}"

    response_body = session.driver.body
    rx = Regexp.new(Regexp.escape(content))

    if negate
      unless response_body !~ rx
        session.fail ContentCheckFailed, "Expected page to not contain #{content}"
      end
    else
      unless response_body =~ rx
        session.fail ContentCheckFailed, "Expected page to contain #{content}"
      end
    end
  end
end
