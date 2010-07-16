class Account < ActiveRecord::Base
  validates_presence_of :name
  
  has_many :user_accounts
  has_many :users, :through => :user_accounts
  
  has_many :sites
  has_many :health_checks, :through => :sites
  has_many :check_runs
  
  named_scope :ordered_by_name, :order => 'name ASC'
  
  def self.from_param!(param)
    find(param)
  end
  
  def user_accounts_with_users
    user_accounts.find(:all, :include => :user, :order => 'users.full_name ASC')
  end
end
