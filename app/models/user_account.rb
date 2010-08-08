class UserAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  
  validates_uniqueness_of :user_id, :scope => :account_id
  
  attr_accessor :email
  
  before_validation :set_user_from_email, :on => :create
  
  after_initialize :extend_role
  
  def extend_role
    extend "Role::Account::#{self.role.classify}".constantize
  end
  
  def self.available_roles
    ['admin', 'user', 'observer']
  end
  
  def self.available_roles_for_select
    available_roles.collect { |role| [I18n.t("account.role.#{role}"), role] }
  end
  
protected
  def set_user_from_email
    return if email.blank?
    
    user_from_email = User.find_by_email(self.email)
    if user_from_email.nil?
      errors.add(:email, I18n.t('activerecord.errors.models.user_account.attributes.email.not_found'))
      false
    else
      self.user = user_from_email
    end
  end
end
