class WaitStep < Step
  property :duration, :integer
  
  def run!(session)
    sleep duration
  end
end
