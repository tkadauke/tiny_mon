class CheckRunMailer < ActionMailer::Base
  def failure(check_run, user)
    subject I18n.t("check_run_mailer.failure.subject", :health_check => check_run.health_check.name, :site => check_run.health_check.site.name)
    recipients user.email
    from "TinyMon <#{TinyMon::Config.email_sender_address}>"
    body :check_run => check_run
  end
end
