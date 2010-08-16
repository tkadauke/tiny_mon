class VisitStep < Step
  property :url, :string
  
  validates_presence_of :url
  
  def run!(session, check_run)
    session.visit(self.url)
  end
end
