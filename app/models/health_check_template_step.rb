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
  
  def build_steps(input)
    if self.condition.blank?
      build_steps_without_condition(input)
    else
      send("build_steps_#{self.condition}", input)
    end
  end
  
  def build_steps_without_condition(input)
    evaluated_params = step_data.data.inject({}) { |hash, pair| key, value = *pair; hash[key] = HealthCheckTemplate.evaluate_string(value, input); hash }
    step_model = "#{step_type}_step".classify.constantize.new(evaluated_params)
  end
  
  def build_steps_if_variable_set(input)
    return nil if input[self.condition_parameter].blank?
    build_steps_without_condition(input)
  end
  
  def build_steps_if_variable_unset(input)
    return nil unless input[self.condition_parameter].blank?
    build_steps_without_condition(input)
  end
  
  def build_steps_if_variable_equals(input)
    return nil unless input[self.condition_parameter] == self.condition_value
    build_steps_without_condition(input)
  end
  
  def build_steps_if_variable_not_equal(input)
    return nil if input[self.condition_parameter] == self.condition_value
    build_steps_without_condition(input)
  end
  
  def build_steps_for_each_element_in_array(input)
    (input[self.condition_parameter] || {}).sort_by(&:first).map do |index, value|
      build_steps_without_condition(input.merge('element' => value))
    end
  end
  
  def build_steps_for_each_key_value_in_hash(input)
    (input[self.condition_parameter] || {}).sort_by(&:first).map do |index, pair|
      key, value = pair['key'], pair['value']
      build_steps_without_condition(input.merge('key' => key, 'value' => value))
    end
  end
end
