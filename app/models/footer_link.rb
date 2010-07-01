class FooterLink < ActiveRecord::Base
  validates_presence_of :text, :url
  
  acts_as_list
  
  named_scope :ordered, :order => 'position ASC'
end
