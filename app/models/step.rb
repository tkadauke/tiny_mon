class Step < ActiveRecord::Base
  include HasProperties
  has_properties :in => :data
  
  belongs_to :health_check
  acts_as_list :scope => :health_check
  
  def self.available_types
    ['visit', 'check_status', 'check_content', 'fill_in', 'select_check_box', 'click_button', 'click_link', 'wait', 'submit_form', 'check_email', 'click_email_link']
  end
  
  def run!(session)
    raise NotImplementedError
  end
end
