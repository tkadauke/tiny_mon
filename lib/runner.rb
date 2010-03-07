class Runner
  def initialize(health_check)
    @health_check = health_check
  end
  
  def run
    session = Session.new(:base_url => @health_check.site.url)
    @health_check.steps.each do |step|
      step.run!(session)
    end
    true
  # rescue
  #   false
  end
end
