class ClickLinkStep < Step
  property :name, :string
  
  validates_presence_of :name
  
  def run!(session)
    session.click_link(self.name)
  end
end
