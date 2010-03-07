class HealthCheck < ActiveRecord::Base
  belongs_to :site
  has_many :steps, :order => 'position ASC'
  has_many :check_runs
  has_many :recent_check_runs, :class_name => 'CheckRun', :order => 'created_at DESC', :limit => 50
  
  has_one :last_check_run, :class_name => 'CheckRun', :order => 'created_at DESC'
  
  named_scope :enabled, :conditions => { :enabled => true }

  has_permalink :name
  
  def self.intervals
    [1, 2, 3, 5, 10, 15, 20, 30, 60]
  end
  
  def check_now?
    Time.now.min % interval == 0
  end
  
  def to_param
    permalink
  end
  
  def self.from_param!(param)
    find_by_permalink!(param)
  end
end
