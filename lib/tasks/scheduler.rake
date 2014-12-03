namespace :scheduler do
  desc "This could be used to run the worker via rake"
  task start: :environment do

    scheduler = Rufus::Scheduler.new

    scheduler.every '30s',  :timeout => '1h' do
      begin
        unless ActiveRecord::Base.connected?
          ActiveRecord::Base.connection.verify!(0)
        end

        HealthCheck.recover_zombies
        HealthCheck.due.each do |check|
          check.prepare_check!
          check.check!
        end

      rescue => e
        puts e.inspect
      ensure
        ActiveRecord::Base.connection_pool.release_connection
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
