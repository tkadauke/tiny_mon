class HealthCheckTemplateStepData
  attr_reader :data
  
  def initialize(attributes = {})
    @data = (attributes || {}).with_indifferent_access
  end
  
  def method_missing(method, *args)
    if @data[method.to_s]
      @data[method.to_s]
    elsif args.size != 0
      super
    end
  end
end
