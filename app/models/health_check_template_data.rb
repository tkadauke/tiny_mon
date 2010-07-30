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
  
  def validate_against_fields(fields)
    fields.each do |hash|
      name, params = hash.keys.first, hash.values.first
      if params['required'] && data[name].blank?
        self.errors.add_to_base([params['name'], I18n.t("activerecord.errors.messages.blank")].join(' '))
      end
    end
  end
end
