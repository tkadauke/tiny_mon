class Step < ActiveRecord::Base
  include HasProperties
  has_properties :in => :data
  
  belongs_to :health_check
  acts_as_list :scope => :health_check
  
  def self.available_types
    ['visit', 'check_status', 'check_content', 'fill_in', 'click_button', 'click_link', 'wait', 'submit_form']
  end
  
  def run!(session)
    raise NotImplementedError
  end
end
