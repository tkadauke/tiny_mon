class Session < Capybara::Session
  class PageNotFound < CheckFailed; end
  class ServerError < CheckFailed; end
  class FieldNotFoundError < CheckFailed; end
  class EmailNotFoundError < CheckFailed; end
  class EmailLinkNotFoundError < CheckFailed; end
  
  attr_accessor :log_entries
  attr_accessor :last_email
  attr_accessor :last_screenshot
  
  def initialize(url)
    @url = url
    @log_entries = []
    
    Capybara.app_host = @url
    super(:poltergeist)
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
    super
  end
  
  def click_link(*args)
    log "Clicking link #{args.first}"
    super
    log "Now on #{driver.current_url}"
  end
  
  def click_button(*args)
    log "Clicking button #{args.first}"
    super
    log "Now on #{driver.current_url}"
  end
  
  def submit_form(locator)
    find(:form, locator, {}).submit({})
  end
  
  def take_screenshot(css)
    log "taking screen shot of URL #{expand_url(driver.current_url)}"
    Dir.create_tmp_dir "renderer", "#{Rails.root}/tmp" do
      driver.render "#{Dir.pwd}/screenshot.png", :full => true
      image_optim = ImageOptim.new
      image_optim.optimize_image!('screenshot.png')
      #system %{pngcrush screenshot.png crushed.png}

      file = ScreenshotFile.store!("screenshot.png", :thumbnail => true)

      self.last_screenshot = Screenshot.new(:checksum => file.checksum)
    end
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
  
  def last_response
    driver.body
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
