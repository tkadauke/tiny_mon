class WaitStep < Step
  property :duration, :integer
  
  def run!(session, check_run)
    sleep duration
  end
end
