class User < ActiveRecord::Base
  acts_as_authentic
  
  has_many :user_accounts
  has_many :accounts, :through => :user_accounts
  
  belongs_to :current_account, :class_name => 'Account'
  
  validates_presence_of :full_name
  
  def switch_to_account(account)
    update_attribute(:current_account_id, account.id)
  end
  
  def can_switch_to_account?(account)
    !UserAccount.find_by_user_id_and_account_id(self.id, account.id).nil?
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
