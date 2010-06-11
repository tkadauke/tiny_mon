require 'net/imap'

class EmailChecker
  class ConnectionFailure < CheckFailed; end
    
  def initialize(server, login, password)
    @server, @login, @password = server, login, password
  end
  
  def check!
    imap = Net::IMAP.new(@server)
    imap.login(@login, @password)
    imap.select('INBOX')
    
    messages = []
    
    imap.search(['ALL']).each do |message_id|
      msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
      messages << TMail::Mail.parse(msg).body
      imap.store(message_id, "+FLAGS", [:Deleted])
    end
    imap.expunge
    imap.disconnect
    
    return messages.last
  rescue Net::IMAP::NoResponseError => e
    raise ConnectionFailure, "No response from email server"
  rescue Net::IMAP::ByeResponseError => e
    raise ConnectionFailure, "'Bye' response from email server"
  rescue Errno::ECONNRESET => e
    raise ConnectionFailure, "Connection reset by email server"
  end
end
