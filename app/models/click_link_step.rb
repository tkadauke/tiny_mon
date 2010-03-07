class ClickLinkStep < Step
  property :name, :string
  
  def run!(session)
    session.click_link(self.name)
  end
end
