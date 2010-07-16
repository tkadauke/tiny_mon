require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Role::UserTest < ActiveSupport::TestCase
  class TestUserAccount
    include Role::Account::Admin
  end
  
  class TestUser
    include Role::User
    def id
      42
    end
  end
  
  def setup
    @user = TestUser.new
  end
  
  test "should be able to edit own profile" do
    assert @user.can_edit_profile?(@user)
  end
  
  test "should not be able to edit another profile" do
    assert ! @user.can_edit_profile?(TestUser.new)
  end
  
  test "should be able to switch to assigned accounts" do
    @user.expects(:user_account_for).returns(TestUserAccount.new)
    assert @user.can_switch_to_account?(stub(:id => 17))
  end
  
  test "should not be able to switch to an unassigned account" do
    @user.expects(:user_account_for).returns(nil)
    assert ! @user.can_switch_to_account?(stub(:id => 17))
  end
  
  test "should be able to remove user from account" do
    @user.expects(:user_account_for).returns(TestUserAccount.new)
    assert @user.can_remove_user_from_account?(TestUser.new, stub(:id => 17))
  end
  
  test "should not be able to remove self from account" do
    assert ! @user.can_remove_user_from_account?(@user, stub)
  end
  
  test "should not be able to do anything else" do
    assert ! @user.can_do_whatever_he_wants?
  end
end
