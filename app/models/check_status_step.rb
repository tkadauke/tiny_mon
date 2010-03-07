class CheckStatusStep < Step
  class StatusCheckFailed < CheckFailed; end
  
  property :status, :integer
  
  def run!(runner)
    unless runner.response.code.to_i == self.status
      raise StatusCheckFailed, "Expected status #{self.status}, got #{runner.response.code}"
    end
  end
end
