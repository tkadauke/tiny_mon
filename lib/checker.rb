class Checker
  def self.run
    loop do
      check_all if Time.now.sec == 0
      sleep 0.5
    end
  end

  def self.check_all
    HealthCheck.enabled.select { |check| check.check_now? }.each do |check|
      begin
        check.check!
      rescue Exception => e
        puts e.message, e.backtrace
      end
    end
  end
end
