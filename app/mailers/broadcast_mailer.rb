class BroadcastMailer < ActionMailer::Base
  default :from => ENV['SMTP_SENDER'] ? ENV['SMTP_SENDER'] : 'TinyMon Notification <notifications@tinymon.org>'

  def broadcast(broadcast, user)
    @broadcast = broadcast
    
    mail :to => user.email, :subject => broadcast.title
  end
end
