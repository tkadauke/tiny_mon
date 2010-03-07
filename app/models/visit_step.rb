class VisitStep < Step
  property :url, :string
  
  def run!(session)
    session.get(self.url)
  end
end
