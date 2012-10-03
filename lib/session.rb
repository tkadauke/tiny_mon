class Session < Webrat::Session
  class PageNotFound < CheckFailed; end
  class ServerError < CheckFailed; end
  class FieldNotFoundError < CheckFailed; end
  class EmailNotFoundError < CheckFailed; end
  class EmailLinkNotFoundError < CheckFailed; end
  class NoScreenshotToCompareError < CheckFailed; end
  
  attr_accessor :log_entries
  attr_accessor :last_email
  attr_accessor :last_screenshot
  
  def initialize(url)
    require 'webrat'
    require 'webrat/mechanize'
    
    @url = url
    @log_entries = []
    
    adapter = Webrat::MechanizeAdapter.new
    adapter.mechanize.open_timeout = 20
    adapter.mechanize.read_timeout = 10
    
    super(adapter)
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
    log "Clicking link #{args.first}"
    super
    log "Now on #{response.uri}"
  end
  
  def click_button(*args)
    log "Clicking button #{args.first}"
    super
    log "Now on #{response.uri}"
  end
  
  def take_screenshot(css)
    log "taking screen shot of URL #{expand_url(response.uri)}"
    renderer = TinyMon::Renderer.new(expand_url(response.uri), adapter.mechanize.cookie_jar.cookies(response.uri), css)
    self.last_screenshot = renderer.render!
  end
  
  def compare_screenshots
    log "comparing screenshot with previous check run"
    if last_screenshot
      screenshots = self.last_screenshot.step.last_two_screenshots
      if screenshots.size == 2
        comparer = TinyMon::ScreenshotComparer.new(*screenshots)
        return comparer.compare!
      else
        log "No previous screenshot found"
      end
    else
      raise NoScreenshotToCompareError, "No screenshot to compare. Please take a screenshot before attempting to compare it agains a previous check run."
    end
    
    nil
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
