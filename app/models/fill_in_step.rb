class FillInStep < Step
  property :field, :string
  property :value, :string
  
  def run!(session)
    session.fill_in(self.field, :with => self.value)
  end
end
