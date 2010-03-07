class HealthCheck < ActiveRecord::Base
  belongs_to :site
  has_many :steps
  has_many :check_runs
  
  def self.intervals
    [1, 2, 3, 5, 10, 15, 20, 30, 60]
  end
  
  def check_now?
    Time.now.min % interval == 0
  end
end
