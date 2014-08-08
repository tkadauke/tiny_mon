class CheckCurrentUrlStep < Step
  class UrlCheckFailed < CheckFailed; end

  property :url, :string
  property :negate, :boolean
  property :check_http_code, :boolean

  validates_presence_of :url

  def run!(session, check_run)
    session.log "Checking current URL against #{self.url}"
    if negate
      session.fail UrlCheckFailed, "Expected current URL to not be #{self.url}, but it was" if session.driver.current_url.to_s == self.url.to_s
    else
      session.fail UrlCheckFailed, "Expected current URL to be #{self.url}, but was #{session.driver.current_url}" unless session.driver.current_url.to_s == self.url.to_s
    end

    status_code = session.status_code
    if status_code != 200 and self.check_http_code
      session.log "Found http code #{status_code}"
      session.fail UrlCheckFailed, "Expected http status to be 200, but received #{status_code}"
    end
  end
end
