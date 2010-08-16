class ClickButtonStep < Step
  property :name, :string
  
  validates_presence_of :name
  
  def run!(session, check_run)
    session.click_button(self.name)
  end
end
