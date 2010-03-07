class VisitStep < Step
  property :url, :string
  
  def run!(runner)
    runner.get(self.url)
  end
end
