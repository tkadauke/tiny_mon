class SelectCheckBoxStep < Step
  property :name, :string
  
  validates_presence_of :name
  
  def run!(session, check_run)
    session.check(self.name)
  end
end
