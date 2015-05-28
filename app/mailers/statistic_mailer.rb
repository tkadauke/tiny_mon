class StatisticMailer < ActionMailer::Base
  default :from => ENV['SMTP_SENDER'] ? ENV['SMTP_SENDER'] : 'TinyMon Notification <notifications@tinymon.org>'


  def daily_stats
    User.all.each do |user|
      if user.config.send_daily_stats
        @stats = get_stats_for_user(user)
        mail :to => user.email, :subject => 'TinyMon Stats'
      end
    end
  end

  private def get_stats_for_user user
    Struct.new('Report',
               :name,
               :no_of_health_checks,
               :no_of_enabled_health_checks,
               :total_check_runs,
               :successfull_check_runs,
               :failed_check_runs,
               :health_checks
    )
    Struct.new('HealthCheckReport',
               :account_name,
               :name,
               :total_check_runs,
               :successfull_check_runs,
               :failed_check_runs)

    accounts = []
    user.accounts.each do |account|
      check_runs = account.check_runs.today.scheduled
      total_check_runs  = check_runs
      successfull_check_runs = check_runs.where(:status => :success)
      failed_check_runs = check_runs.where(:status => :failure)
      health_checks = []
      account.health_checks.each do |health_check|
        hc_total_check_runs  = total_check_runs.count
        hc_successfull_check_runs = check_runs.where(:status => :success).count
        hc_failed_check_runs = check_runs.where(:status => :failure).count
        health_checks << Struct::HealthCheckReport.new(
            account.name,
            health_check.name,
            hc_total_check_runs,
            hc_successfull_check_runs,
            hc_failed_check_runs
        )
      end
      accounts <<  Struct::Report.new(
        account.name,
        account.health_checks.count,
        account.health_checks.enabled.count,
        total_check_runs.count,
        successfull_check_runs.count,
        failed_check_runs.count,
        health_checks
              )
    end

    accounts

  end

end



