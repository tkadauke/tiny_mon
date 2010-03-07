class ClickButtonStep < Step
  property :name, :string
  
  def run!(session)
    session.click_button(self.name)
  end
end
