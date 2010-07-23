class FillInStep < Step
  property :field, :string
  property :value, :string
  
  validates_presence_of :field
  
  def run!(session, check_run)
    session.fill_in(self.field, :with => self.value)
  end
end
