class FillInDateStep < ScopableStep
  property :field, :string
  property :value, :integer
  property :dateformat, :string
  property :set_value_direct, :boolean

  validates_presence_of :field
  
  def run!(session, check_run)
    with_optional_scope(session) do
      now = DateTime.now
      date = now - (value.to_i).days
      if set_value_direct
        session.find(self.field).set(date.to_s)
      else
        session.fill_in(self.field, :with => date)
      end
      #TODO: Format date if dateformat is set
    end
  end
end
