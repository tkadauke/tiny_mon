class WaitStep < Step
  property :duration, :integer
  
  def run!(session, check_run)
    session.log "Wait for #{duration} seconds"
    sleep duration
  end
end
