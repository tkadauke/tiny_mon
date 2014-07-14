class GoBackStep < Step

  property :count, :integer

  def run!(session, check_run)
    session.log "Go back"
    count.times do
      session.go_back()
      sleep 1
      session.find('body')
    end
  end
end
