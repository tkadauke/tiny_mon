class HealthCheckTemplateVariable < ActiveRecord::Base
  self.inheritance_column = nil
  
  validates_presence_of :name, :display_name, :type
  
  acts_as_list
  
  def self.available_types
    ['string']
  end
  
  def self.available_types_with_translations
    available_types.collect { |type| [I18n.t("health_check_template.variable.type.#{type}"), type] }
  end
end
