require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '10s' do
  HealthCheck.recover_zombies
  HealthCheck.due.each do |check|
    check.prepare_check!
    check.check!
  end
end

scheduler.cron '5 0 * * *' do
  # do something every day, five minutes after midnight
  # (see "man 5 crontab" in your terminal)
  StatisticMailer.daily_stats.deliver
end

#scheduler.join