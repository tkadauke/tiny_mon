class CheckRunMailer < ActionMailer::Base
  def failure(check_run)
    subject I18n.t("check_run_mailer.failure.subject", :health_check => check_run.health_check, :site => check_run.health_check.site)
    recipients TinyMon::Config.recipient_email
    from TinyMon::Config.email_sender_address
    body :check_run => check_run
  end
end
