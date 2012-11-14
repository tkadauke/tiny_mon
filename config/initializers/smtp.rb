ActionMailer::Base.smtp_settings = {
  :domain => TinyMon::Config.email_domain,
  :address => TinyMon::Config.email_address,
  :port => TinyMon::Config.email_port,
  :user_name => TinyMon::Config.email_user_name,
  :password => TinyMon::Config.email_password,
  :authentication => TinyMon::Config.email_authentication.to_sym,
  :openssl_verify_mode => TinyMon::Config.email_openssl_verify_mode.to_sym,
  :enable_starttls_auto => TinyMon::Config.email_enable_starttls_auto
}
