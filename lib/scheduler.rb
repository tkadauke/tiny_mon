class Scheduler
  def self.run
    loop do
      check_all
      sleep 1
    end
  end

  def self.check_all
    HealthCheck.due.each do |check|
      check.schedule_next!
      check.check!
    end
  end
end
