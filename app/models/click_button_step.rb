class ClickButtonStep < Step
  property :name, :string
  
  validates_presence_of :name
  
  def run!(session)
    session.click_button(self.name)
  end
end
