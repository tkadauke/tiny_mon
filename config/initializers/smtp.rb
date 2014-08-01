ActionMailer::Base.smtp_settings = {
  :domain => TinyMon::Config.email_domain.to_s,
  :address => TinyMon::Config.email_address.to_s,
  :port => TinyMon::Config.email_port.to_i,
  :user_name => TinyMon::Config.email_user_name.to_s,
  :password => TinyMon::Config.email_password.to_s,
  :authentication => TinyMon::Config.email_authentication.to_sym,
  :openssl_verify_mode => TinyMon::Config.email_openssl_verify_mode.to_sym,
  :enable_starttls_auto => TinyMon::Config.email_enable_starttls_auto
}
