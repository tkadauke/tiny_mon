class CheckTextStep < Step
  class CheckTextFailed < CheckFailed; end

  property :content, :string
  property :negate, :boolean


  validates_presence_of :content

  def run!(session, check_run)
    session.log "Checking visible content for #{content} (negate: #{negate})"

    if negate
      if session.has_text?(content, :visible => false)
        session.fail CheckTextFailed, "Expected page to not contain #{content}"
      end
    else
      if session.has_no_text?(content, :visible => false)
        session.fail CheckTextFailed, "Expected page to contain #{content}"
      end
    end
  end
end
