class ScopableStep < Step
  property :scope, :string
  
protected
  def with_optional_scope(session, &block)
    if scope.blank?
      yield session
    else
      session.within scope do |selector|
        yield selector
      end
    end
  end
end
