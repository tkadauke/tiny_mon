class BroadcastMailer < ActionMailer::Base
  default :from => "TinyMon <#{TinyMon::Config.email_sender_address}>"
  
  def broadcast(broadcast, user)
    @broadcast = broadcast
    
    mail :to => user.email, :subject => broadcast.title
  end
end
