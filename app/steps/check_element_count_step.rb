class CheckElementCountStep < ScopableStep
  class CheckElementCountFailed < CheckFailed; end

  property :name, :string
  property :maxcount, :integer
  property :mincount, :integer

  validates_presence_of :name
  validates_presence_of (:mincount || :maxcount)

  def run!(session, check_run)
    session.log "Checking count for #{name} (#{mincount} <= count <= #{maxcount})"
    session.assert_selector(name, :minimum => mincount) unless :mincount.nil?
    session.assert_selector(name, :maximum => maxcount) unless :maxcount.nil?
  end

end

