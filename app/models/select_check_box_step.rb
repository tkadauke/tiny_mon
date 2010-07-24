class SelectCheckBoxStep < Step
  property :name, :string
  
  validates_presence_of :name
  
  def run!(session)
    session.check(self.name)
  end
end
