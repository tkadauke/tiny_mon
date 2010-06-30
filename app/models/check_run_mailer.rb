class CheckRunMailer < ActionMailer::Base
  def failure(check_run)
    subject I18n.t("check_run_mailer.failure.subject", :health_check => check_run.health_check.name, :site => check_run.health_check.site.name)
    recipients TinyMon::Config.recipient_email
    from "TinyMon <#{TinyMon::Config.email_sender_address}>"
    body :check_run => check_run
  end
end
