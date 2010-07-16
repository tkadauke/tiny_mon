require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Role::Account::AdminTest < ActiveSupport::TestCase
  class TestAdminAccount
    include Role::Account::Admin
  end
  
  def setup
    @user = TestAdminAccount.new
  end
  
  test "should be able to do anything else" do
    assert @user.can_do_whatever_he_wants?
  end
  
  test "should not catch other methods" do
    assert_raise NoMethodError do
      @user.foobar
    end
  end
end
