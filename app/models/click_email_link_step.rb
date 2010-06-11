class ClickEmailLinkStep < Step
  property :link_pattern, :string
  
  def run!(session)
    session.click_email_link(self.link_pattern)
  end
end
