require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UserAccountTest < ActiveSupport::TestCase
  test "should return available roles" do
    assert UserAccount.available_roles.is_a?(Array)
  end
end
