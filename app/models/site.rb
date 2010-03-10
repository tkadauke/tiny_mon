class Site < ActiveRecord::Base
  has_many :health_checks
  
  has_permalink :name
  
  validates_presence_of :name, :url
  
  def to_param
    permalink
  end
  
  def self.from_param!(param)
    find_by_permalink!(param)
  end
end
