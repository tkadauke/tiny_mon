module Role::User
  include Role::Base
  
  def can_edit_profile?(user)
    user == self
  end
  
  def can_switch_to_account?(account)
    !UserAccount.find_by_user_id_and_account_id(self.id, account.id).nil?
  end
  
  alias_method :can_see_account?, :can_switch_to_account?
  alias_method :can_edit_account?, :can_switch_to_account?
  alias_method :can_add_user_to_account?, :can_switch_to_account?
  
  def can_remove_user_from_account?(user, account)
    user != self && can_switch_to_account?(account)
  end
end
