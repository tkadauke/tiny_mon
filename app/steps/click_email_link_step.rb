class ClickEmailLinkStep < Step
  property :link_pattern, :string
  
  validates_presence_of :link_pattern
  
  def run!(session, check_run)
    session.click_email_link(self.link_pattern)
  end
end
