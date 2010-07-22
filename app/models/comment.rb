class Comment < ActiveRecord::Base
  belongs_to :check_run
  belongs_to :user
  
  validates_presence_of :text
end
