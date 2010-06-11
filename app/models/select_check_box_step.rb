class SelectCheckBoxStep < Step
  property :name, :string
  
  def run!(session)
    session.check(self.name)
  end
end
