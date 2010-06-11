class Session < Webrat::Session
  class PageNotFound < CheckFailed; end
  class ServerError < CheckFailed; end
  class FieldNotFoundError < CheckFailed; end
  class EmailNotFoundError < CheckFailed; end
  class EmailLinkNotFoundError < CheckFailed; end
  
  attr_accessor :log_entries
  attr_accessor :last_email
  
  def initialize(url)
    require 'webrat'
    require 'webrat/mechanize'
    
    @url = url
    @log_entries = []
    super(Webrat::MechanizeAdapter.new)
  end
  
  def log(message)
    log_entries << [Time.now, message]
  end
  
  def fail(exception_class, message)
    log message
    raise exception_class, message
  end
  
  def visit(url)
    log "getting #{url}"
    super(expand_url(url))
  rescue Webrat::PageLoadError
    raise ServerError, "Internal Server Error when trying to load #{url}"
  end
  
  def click_link(*args)
    log "clicking link #{args.first}"
    super
    log "now on #{current_url}"
  end
  
  def click_button(*args)
    log "clicking button #{args.first}"
    super
    log "now on #{current_url}"
  end
  
  def debug_log(*args)
    log(*args)
  end
  
  def check_email(server, login, password)
    self.last_email = EmailChecker.new(server, login, password).check!
  end
  
  def click_email_link(link_pattern)
    raise EmailNotFoundError, "No email found to click link in" if last_email.blank?
    
    link = last_email.split("\n").grep(Regexp.new(Regexp.escape(link_pattern))).first
    if link
      visit(link.strip)
    else
      raise EmailLinkNotFoundError, "Link with pattern #{link_pattern} not found in email"
    end
  end
  
protected
  def expand_url(url)
    if url =~ /^http/
      URI.parse(url)
    else
      URI.join(@url, url)
    end
  end
  
  # dont use webrat logger
  def logger
    nil
  end
end
