class UserAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :account
  
  validates_uniqueness_of :user_id, :scope => :account_id
  
  attr_accessor :email
  
  before_validation_on_create :set_user_from_email
  
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
