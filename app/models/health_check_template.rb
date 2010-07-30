class HealthCheckTemplate < ActiveRecord::Base
  belongs_to :user
  
  named_scope :public_templates, :conditions => 'public'
  
  def self.from_param!(param)
    find(param)
  end
  
  def evaluate_name(data)
    evaluate_string(name_template, data)
  end
  
  def evaluate_description(data)
    evaluate_string(description_template, data)
  end
  
  def evaluate_steps(data)
    steps.collect do |hash|
      name, params = hash.keys.first, hash.values.first
      
      evaluated_params = params.inject({}) { |hash, pair| key, value = *pair; hash[key] = evaluate_string(value, data); hash }
      step_model = "#{name}_step".classify.constantize.new(evaluated_params)
    end
  end
  
  def steps
    YAML.load(steps_template)
  end
  
  def fields
    YAML.load(variables)
  end

private
  def evaluate_string(string, data)
    data.stringify_keys!
    (string || "").gsub(/\{\{(.*?)\}\}/) do
      data[$1]
    end
  end
end
