class Checker
  def self.run
    loop do
      check_all if Time.now.sec == 0
      sleep 0.5
    end
  end
  
  def self.check_all
    HealthCheck.enabled.each do |check|
      next unless check.check_now?
      
      runner = Runner.new(check)
      attrs = { :started_at => Time.now.to_f, :status => 'success' }
      
      retry_times = 3
      begin
        runner.run!
      rescue CheckFailed => e
        retry_times -= 1
        retry unless retry_times == 0
        
        attrs[:status] = 'failure'
        attrs[:error_message] = e.message
      end
      attrs[:ended_at] = Time.now.to_f
      attrs[:log] = runner.log_entries
      
      check.check_runs.create(attrs)
    rescue Exception => e
      puts e.message, e.backtrace
    end
  end
end
