ActionMailer::Base.smtp_settings = {
  :domain => TinyCore::Config.email_domain,
  :address => TinyCore::Config.email_address,
  :port => TinyCore::Config.email_port,
  :user_name => TinyCore::Config.email_user_name,
  :password => TinyCore::Config.email_password,
  :authentication => TinyCore::Config.email_authentication.to_sym
}
