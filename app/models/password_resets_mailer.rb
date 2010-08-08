class PasswordResetsMailer < ActionMailer::Base
  default :from => "TinyMon <#{TinyMon::Config.email_sender_address}>"

  def password_reset_instructions(user)
    @edit_password_reset_path = edit_password_reset_path(user.perishable_token)
    
    mail :to => user.email, :subject => I18n.t("password_reset_mailer.subject")
  end
end
