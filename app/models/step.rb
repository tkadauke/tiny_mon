class Step < ActiveRecord::Base
  include HasProperties
  has_properties :in => :data
  
  belongs_to :health_check
  acts_as_list :scope => :health_check
  
  attr_accessor :insert_after
  
  after_save :reorder_steps
  
  def self.available_types
    ['visit', 'check_status', 'check_content', 'check_current_url', 'fill_in', 'select_check_box', 'click_button', 'click_link', 'wait', 'submit_form', 'check_email', 'click_email_link']
  end
  
  def self.available_types_with_translations
    available_types.collect { |t| [I18n.t("step.#{t}"), t] }
  end
  
  def run!(session)
    raise NotImplementedError
  end
  
  def reorder_steps
    return if insert_after.blank? || @inserting
    @inserting = true
    
    insert_at_position(insert_after.to_i + 1)
  end
  
  def underscored_class_name
    self.class.name.gsub(/Step$/, '').underscore
  end
end
