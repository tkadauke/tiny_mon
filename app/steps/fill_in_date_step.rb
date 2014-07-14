class FillInDateStep < ScopableStep
  property :field, :string
  property :value, :integer
  property :dateformat, :string

  validates_presence_of :field
  
  def run!(session, check_run)
    with_optional_scope(session) do
      now = DateTime.now
      date = now - (value.to_i).days
      session.fill_in(self.field, :with => date)
      #TODO: Format date if dateformat is set
    end
  end
end
