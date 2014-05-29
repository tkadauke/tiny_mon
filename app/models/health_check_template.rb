class HealthCheckTemplate < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  
  scope :public_templates, lambda { where('public') }
  
  validates_presence_of :user_id, :name, :name_template, :interval
  
  has_many :variables, lambda { order('position ASC') }, :class_name => 'HealthCheckTemplateVariable', :dependent => :delete_all
  accepts_nested_attributes_for :variables, :allow_destroy => true
  
  has_many :steps, lambda { order('position ASC') }, :class_name => 'HealthCheckTemplateStep', :dependent => :delete_all
  accepts_nested_attributes_for :steps, :allow_destroy => true
  
  def self.from_param!(param)
    find(param)
  end
  
  def evaluate_name(data)
    self.class.evaluate_string(name_template, data)
  end
  
  def evaluate_description(data)
    self.class.evaluate_string(description_template, data)
  end
  
  def evaluate_steps(data)
    steps.collect { |step| step.build_steps(data) }.flatten.compact
  end
  
  def validate_health_check_data(health_check, data)
    data.validate_against_variables(variables)
  end

  def self.evaluate_string(string, data)
    (string || "").gsub(/\{\{(.*?)\}\}/) do
      value = data[$1]
      case value
      when Hash
        value.sort_by { |x| x.first.to_i }.collect { |x| x.last }.join(', ')
      else
        value
      end
    end
  end
end
