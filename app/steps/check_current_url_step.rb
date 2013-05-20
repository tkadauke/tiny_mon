class CheckCurrentUrlStep < Step
  class UrlCheckFailed < CheckFailed; end

  property :url, :string
  property :negate, :boolean
  
  validates_presence_of :url
  
  def run!(session, check_run)
    if negate
      session.fail UrlCheckFailed, "Expected current URL to not be #{self.url}, but it was" if session.response.uri.to_s == self.url.to_s
    else
      session.fail UrlCheckFailed, "Expected current URL to be #{self.url}, but was #{session.response.uri}" unless session.response.uri.to_s == self.url.to_s
    end
  end
end
