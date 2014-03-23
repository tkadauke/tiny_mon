class Account < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :user_accounts
  has_many :users, :through => :user_accounts
  
  has_many :sites
  has_many :health_checks, :through => :sites
  has_many :enabled_health_checks, :through => :sites, :source => :health_checks, :conditions => { :enabled => true }
  has_many :health_check_templates
  has_many :health_check_imports
  has_many :check_runs
  has_many :comments
  has_many :screenshots, :through => :check_runs
  
  scope :ordered_by_name, order('name ASC')
  
  #attr_protected :maximum_check_runs_per_day, :check_runs_per_day
  
  def self.from_param!(param)
    find(param)
  end
  
  def all_checks_successful?
    health_checks.failed.count == 0
  end
  
  def status
    all_checks_successful? ? 'success' : 'failure'
  end
  
  def user_accounts_with_users
    user_accounts.includes(:user).order('users.full_name ASC')
  end

  def self.filter_for_list(filter)
    with_search_scope(filter).order('accounts.name ASC')
  end
  
  def update_attributes_without_attr_protected(attributes)
    attributes.each do |key, value|
      self.send("#{key}=", value)
    end
    save
  end
  
  def update_check_runs_per_day
    self.check_runs_per_day = enabled_health_checks.map(&:check_runs_per_day).sum
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
  
  def as_json(options = {})
    super.merge(
      :status => status,
      :role => (options[:for].user_account_for(self).role if options[:for])
    )
  end

protected
  def self.with_search_scope(filter, &block)
    conditions = filter.empty? ? nil : ['accounts.name LIKE ?', "%#{filter.query}%"]
    where(conditions)
  end
end
