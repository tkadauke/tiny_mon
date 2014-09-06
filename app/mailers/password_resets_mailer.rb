class PasswordResetsMailer < ActionMailer::Base
  default :from => ENV['SMTP_SENDER'] ? ENV['SMTP_SENDER'] : 'TinyMon Notification <notifications@tinymon.org>'

  def password_reset_instructions(user)
    @edit_password_reset_path = edit_password_reset_path(user.perishable_token, :locale => user.config.language)
    
    mail :to => user.email, :subject => I18n.t("password_reset_mailer.subject")
  end
end
