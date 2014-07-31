class VisitStep < Step
  property :url, :string
  property :check_http_code, :boolean
  validates_presence_of :url
  
  def run!(session, check_run)
    # Add DoNotTrack header
    session.driver.add_headers("DNT" => "1")
    session.visit(self.url)
    #TODO Check if http response state != 200
    status_code = session.status_code
   # if status_code != 200  and property :negate, :boolean
   #   session.fail ContentCheckFailed, "Expected http status to be 200, but received #{status_code}"
   # end
  end
end
