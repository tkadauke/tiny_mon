class Account < ActiveRecord::Base
  acts_as_account
  
  has_many :sites
  has_many :health_checks, :through => :sites
  has_many :health_check_templates
  has_many :health_check_imports
  has_many :check_runs
  has_many :comments
  has_many :screenshots, :through => :check_runs
  
  attr_protected :maximum_check_runs_per_day, :check_runs_per_day
  
  def all_checks_successful?
    health_checks.count(:conditions => { :status => 'failure', :enabled => true }) == 0
  end
  
  def update_check_runs_per_day
    self.check_runs_per_day = health_checks.map(&:check_runs_per_day).sum
    save
  end
  
  def unlimited_check_runs?
    maximum_check_runs_per_day == 0
  end
  
  def over_maximum_check_runs_per_day?
    !unlimited_check_runs? && check_runs_per_day > maximum_check_runs_per_day
  end
  
  def scheduled_check_runs_today
    @scheduled_check_runs_today ||= check_runs.today.scheduled.count
  end
  
  def over_maximum_check_runs_today?
    !unlimited_check_runs? && scheduled_check_runs_today > maximum_check_runs_per_day
  end
end
