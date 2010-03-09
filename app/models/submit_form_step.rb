class SubmitFormStep < Step
  property :name, :string
  
  def run!(session)
    session.log "submitting form #{name}"
    session.submit_form name
  end
end
