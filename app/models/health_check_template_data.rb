class HealthCheckTemplateData
  attr_reader :data
  
  def initialize(attributes = {})
    @data = attributes.stringify_keys
  end
  
  def method_missing(method, *args)
    if @data[method.to_s]
      @data[method.to_s]
    elsif args.size != 0
      super
    end
  end
  
  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end
  
  def [](index)
    data[index]
  end
  
  def validate_against_variables(variables)
    variables.each do |variable|
      if variable.required? && data[variable.name].blank?
        self.errors.add_to_base([variable.display_name, I18n.t("activerecord.errors.messages.blank")].join(' '))
      end
    end
  end

  def merge(hash)
    self.class.new(self.data.merge(hash))
  end
end
