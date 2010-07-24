class VisitStep < Step
  property :url, :string
  
  validates_presence_of :url
  
  def run!(session)
    session.visit(self.url)
  end
end
