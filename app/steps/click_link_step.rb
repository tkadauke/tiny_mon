class ClickLinkStep < Step
  property :name, :string
  
  validates_presence_of :name
  
  def run!(session, check_run)
    session.click_link(self.name)
  end
end
