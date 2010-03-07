class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  
  serialize :log, Array
  
  after_create :update_health_check_status
  
  named_scope :recent, :order => 'created_at DESC', :limit => 10
  
  def duration
    (self.ended_at - self.started_at).to_f
  end
  
  def self.from_param!(param)
    find(param)
  end
  
protected
  def update_health_check_status
    health_check.update_attribute(:status, self.status)
  end
end
