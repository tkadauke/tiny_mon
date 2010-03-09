class Session < Webrat::Session
  class PageNotFound < CheckFailed; end
  class ServerError < CheckFailed; end
  class FieldNotFoundError < CheckFailed; end
  
  attr_accessor :log_entries
  
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
