class CheckCurrentUrlStep < Step
  class UrlCheckFailed < CheckFailed; end

  property :url, :string
  
  validates_presence_of :url
  
  def run!(session, check_run)
    session.fail UrlCheckFailed, "Expected current URL to be #{self.url}, but was #{session.response.uri}" unless session.response.uri.to_s == self.url.to_s
  end
end
