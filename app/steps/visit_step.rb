class VisitStep < Step
  property :url, :string
  
  validates_presence_of :url
  
  def run!(session, check_run)
    session.driver.add_headers("DNT" => "1")
    session.visit(self.url)
  end
end
