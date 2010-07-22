class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :user_accounts
  has_many :accounts, :through => :user_accounts
  has_many :config_options
  has_many :comments
  has_many :latest_comments, :class_name => 'Comment', :order => 'created_at DESC', :limit => 5
  
  belongs_to :current_account, :class_name => 'Account'
  
  validates_presence_of :full_name
  
  attr_protected :role
  
  def after_initialize
    if self.role.blank?
      extend Role::User
    else
      extend "Role::#{self.role.classify}".constantize
    end
  end
  
  def switch_to_account(account)
    update_attribute(:current_account_id, account.id)
  end
  
  def set_role_for_account(account, role)
    user_account_for(account).update_attribute(:role, role)
  end
  
  def user_account_for(account)
    UserAccount.find_by_user_id_and_account_id(self.id, account.id)
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    PasswordResetsMailer.deliver_password_reset_instructions(self)
  end
  
  def self.from_param!(param)
    find(param)
  end
  
  def name
    full_name
  end
  
  def config
    @config ||= User::Configuration.new(self)
  end
end
