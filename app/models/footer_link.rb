class FooterLink < ActiveRecord::Base
  validates_presence_of :text, :url
  
  acts_as_list
  
  scope :ordered, order('position ASC')
end
