class Runner
  attr_reader :session
  
  def initialize(check_run)
    @check_run = check_run
    @health_check = check_run.health_check
  end
  
  def run!
    begin
      @session = Session.new(@health_check.site.url)
      @health_check.steps.each do |step|
        step.run!(session, @check_run)
      end
      true
    ensure
      @session.driver.quit
    end
  end
  
  delegate :log, :log_entries, :to => :session
end
