begin
  require 'exception_notification'
  
  ApplicationController.send :include, ExceptionNotification::Notifiable
  
  ExceptionNotification::Notifier.exception_recipients = TinyCore::Config.exception_recipients
  ExceptionNotification::Notifier.sender_address = TinyCore::Config.exception_sender_address
  
  ExceptionNotification::Notifier.email_prefix = "[TinyMon] "
rescue LoadError => e
end
