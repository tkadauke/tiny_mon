namespace :scheduler do
  desc "This could be used to run the worker via rake"
  task start: :environment do

    scheduler = Rufus::Scheduler.new

    scheduler.every '10s',  :timeout => '1h' do
      begin
        HealthCheck.recover_zombies
        HealthCheck.due.each do |check|
          check.prepare_check!
          check.check!
        end
      rescue Rufus::Scheduler::TimeoutError
        #somehow mark this as failed
        puts 'timeout'
      end
    end

    scheduler.cron '5 0 * * *' do
      # do something every day, five minutes after midnight
      # (see "man 5 crontab" in your terminal)
      StatisticMailer.daily_stats.deliver
    end

    scheduler.join
  end
end
