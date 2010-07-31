class HealthCheckTemplateStep < ActiveRecord::Base
  belongs_to :health_check_template
  
  serialize :step_data_hash, Hash
  
  attr_accessor :step_data
  
  acts_as_list :scope => :health_check_template
  
  def step_data
    @step_data ||= HealthCheckTemplateStepData.new(self.step_data_hash)
  end
  
  def step_data=(value)
    @step_data = HealthCheckTemplateStepData.new(value)
  end
  
  def before_save
    self.step_data_hash = self.step_data.data
  end

  def self.condition_types
    ['if_variable_set', 'if_variable_unset', 'if_variable_equals', 'if_variable_not_equal', 'for_each_element_in_array', 'for_each_key_value_in_hash']
  end
  
  def self.condition_types_with_translations
    condition_types
  end
end
