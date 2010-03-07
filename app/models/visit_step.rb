class VisitStep < Step
  property :url, :string
  
  def run!(session)
    session.visit(self.url)
  end
end
