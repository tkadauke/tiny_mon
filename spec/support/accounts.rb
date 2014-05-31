module AccountsTestHelper
  def demote(user, account, role = 'observer')
    user.user_account_for(account).update_attributes(:role => role)
  end
end

RSpec.configure do |config|
  config.include AccountsTestHelper, type: :controller
end
