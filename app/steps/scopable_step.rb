class ScopableStep < Step
  property :scope, :string
  
protected
  def with_optional_scope(session, &block)
    if scope.blank?
      yield
    else
      session.within scope do
        yield
      end
    end
  end
end
