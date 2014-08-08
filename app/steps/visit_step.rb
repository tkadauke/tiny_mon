class VisitStep < Step
  property :url, :string
  validates_presence_of :url
  
  def run!(session, check_run)
    # Add DoNotTrack header
    session.driver.add_headers("DNT" => "1")
    session.visit(self.url)

  end
end
