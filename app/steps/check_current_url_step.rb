class CheckCurrentUrlStep < Step
  class UrlCheckFailed < CheckFailed; end

  property :url, :string
  property :negate, :boolean
  
  validates_presence_of :url
  
  def run!(session, check_run)
    session.log "Checking current URL against #{self.url}"
    if negate
      session.fail UrlCheckFailed, "Expected current URL to not be #{self.url}, but it was" if session.driver.current_url.to_s == self.url.to_s
    else
      session.fail UrlCheckFailed, "Expected current URL to be #{self.url}, but was #{session.driver.current_url}" unless session.driver.current_url.to_s == self.url.to_s
    end
  end
end
