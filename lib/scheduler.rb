class Scheduler
  def self.run
    loop do
      check_all
      sleep 10
    end
  end

  def self.check_all
    HealthCheck.recover_zombies
    HealthCheck.due.each do |check|
      Thread.new {
        check.prepare_check!
        check.check!
      }
    end
  end
end
