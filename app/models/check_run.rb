class CheckRun < ActiveRecord::Base
  belongs_to :health_check
  
  serialize :log, Array
  
  def duration
    self.ended_at - self.started_at
  end
end
