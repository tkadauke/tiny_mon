class Checker
  def self.run
    loop do
      check_all if Time.now.sec == 0
      sleep 0.5
    end
  end
  
  def self.check_all
    HealthCheck.all.each do |check|
      runner = Runner.new(check)
      attrs = { :started_at => Time.now, :status => 'success' }
      
      begin
        runner.run!
      rescue CheckFailed => e
        attrs[:status] = 'failure'
        attrs[:error_message] = e.message
      end
      attrs[:ended_at] = Time.now
      attrs[:log] = runner.log_entries
      
      check.check_runs.create(attrs)
    end
  end
end
