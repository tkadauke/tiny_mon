module Role::Locked
  include Role::Base
  
  def can_see_profile?(user)
    user == self
  end

  def can_see_account?(account)
    !user_account_for(account).nil?
  end
end
