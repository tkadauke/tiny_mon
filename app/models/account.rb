class Account < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :user_accounts
  has_many :users, :through => :user_accounts
  
  has_many :sites
  has_many :health_checks, :through => :sites
  has_many :health_check_templates
  has_many :health_check_imports
  has_many :check_runs
  has_many :comments
  
  scope :ordered_by_name, order('name ASC')
  
  def self.from_param!(param)
    find(param)
  end
  
  def all_checks_successful?
    health_checks.failed.count == 0
  end
  
  def user_accounts_with_users
    user_accounts.includes(:user).order('users.full_name ASC')
  end

  def self.filter_for_list(filter)
    with_search_scope(filter).order('accounts.name ASC')
  end

protected
  def self.with_search_scope(filter, &block)
    conditions = filter.empty? ? nil : ['accounts.name LIKE ?', "%#{filter.query}%"]
    where(conditions)
  end
end
