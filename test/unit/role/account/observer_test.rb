require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Role::Account::ObserverTest < ActiveSupport::TestCase
  class TestObserverAccount
    include Role::Account::Observer
  end
  
  def setup
    @user = TestObserverAccount.new
  end
  
  test "should not be able to do anything interesting" do
    assert ! @user.can_do_whatever_he_wants?
  end
  
  test "should not catch other methods" do
    assert_raise NoMethodError do
      @user.foobar
    end
  end
end
