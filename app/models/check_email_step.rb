class CheckEmailStep < Step
  property :server, :string
  property :login, :string
  property :password, :string
  
  def run!(session)
    session.check_email(server, login, password)
  end
end
