class Deployment < ActiveRecord::Base
  belongs_to :site
  
  has_many :check_runs
  
  attr_accessor :schedule_checks_in
  
  def self.from_param!(param)
    find(param)
  end
  
  def schedule_checks!
    return unless schedule_checks_in
    
    site.health_checks.enabled.each do |health_check|
      health_check.schedule_next_check(schedule_checks_in.to_i.minutes.from_now)
    end
  end
  
  def all_checks_successful?
    check_runs.where(:status => 'failure').count == 0
  end
end
