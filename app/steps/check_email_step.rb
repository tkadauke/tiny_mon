class CheckEmailStep < Step
  property :server, :string
  property :login, :string
  property :password, :string
  
  validates_presence_of :server, :login, :password
  
  def run!(session, check_run)
    session.check_email(server, login, password)
  end
end
