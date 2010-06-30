class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :user_accounts
  has_many :accounts, :through => :user_accounts
  
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
end
