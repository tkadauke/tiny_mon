class CheckContentStep < Step
  class ContentCheckFailed < CheckFailed; end

  property :content, :string
  
  def run!(runner)
    raise ContentCheckFailed, "Expected page to contain #{content}" unless runner.response.body =~ Regexp.new(Regexp.escape(content))
  end
end
