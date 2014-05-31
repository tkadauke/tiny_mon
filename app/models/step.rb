class Step < ActiveRecord::Base
  include HasProperties
  has_properties :in => :data
  
  has_many :screenshots
  has_many :last_two_screenshots, lambda { order('created_at DESC').limit(2) }, :class_name => 'Screenshot'
  belongs_to :health_check
  acts_as_list :scope => :health_check
  
  attr_accessor :insert_after
  
  after_save :reorder_steps
  
  def self.available_types
    [
      'visit',
      'check_content',
      'check_current_url',
      'fill_in',
      'check_element_count',
      'select_check_box',
      'deselect_check_box',
      'choose_radio_button',
      'select_dropdown',
      'click_button',
      'click_link',
      'wait',
      'submit_form',
      'check_email',
      'click_email_link',
      'take_screenshot',
      'run_script'
    ]
  end
  
  def self.available_types_with_translations
    available_types.collect { |t| [I18n.t("step.#{t}"), t] }
  end
  
  def run!(session, check_run)
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
  
  def as_json(options = {})
    attributes
  end
end
