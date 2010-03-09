class Checker
  def self.run
    loop do
      check_all if Time.now.sec == 0
      sleep 0.5
    end
  end

  def self.check_all
    HealthCheck.enabled.each do |check|
      begin
        next unless check.check_now?
        
        check.check!
      rescue Exception => e
        puts e.message, e.backtrace
      end
    end
  end
end
