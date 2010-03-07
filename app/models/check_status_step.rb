class CheckStatusStep < Step
  class StatusCheckFailed < CheckFailed; end
  
  property :status, :integer
  
  def run!(session)
    session.log "Checking status (expecting #{status})"
    unless session.response.code.to_i == self.status
      raise StatusCheckFailed, "Expected status #{self.status}, got #{session.response.code}"
    end
  end
end
