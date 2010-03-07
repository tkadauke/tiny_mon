class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  
  serialize :log, Array
  
  after_create :update_health_check_status
  
  def duration
    self.ended_at - self.started_at
  end
  
protected
  def update_health_check_status
    health_check.update_attribute(:status, self.status)
  end
end
