require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class AccountsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @user.set_role_for_account(@account, 'admin')
    
    login_with @user
  end
  
  test "should show account index" do
    get :index
    assert_response :success
  end
  
  test "should show new" do
    get :new
    assert_response :success
  end
  
  test "should show edit" do
    get :edit, :id => @account
    assert_response :success
  end
  
  test "should show account info" do
    get :show, :id => @account
    assert_response :success
  end
  
  test "should create account" do
    assert_difference 'Account.count' do
      assert_difference 'UserAccount.count' do
        post :create, :account => { :name => 'other account' }
        assert_response :redirect
        assert_not_nil flash[:notice]
      end
    end
  end
  
  test "should not create invalid account" do
    assert_no_difference 'Account.count' do
      assert_no_difference 'UserAccount.count' do
        post :create, :account => { :name => nil }
        assert_response :success
        assert_nil flash[:notice]
      end
    end
  end
  
  test "should update account" do
    post :update, :id => @account, :account => { :name => 'changed name' }
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_equal 'changed name', @account.reload.name
  end
  
  test "should not update invalid account" do
    post :update, :id => @account, :account => { :name => nil }
    assert_response :success
    assert_nil flash[:notice]
    assert_equal 'account', @account.reload.name
  end
  
  test "should switch account" do
    @second_account = @user.accounts.create(:name => 'second account')
    post :switch, :id => @second_account
    assert_not_nil flash[:notice]
    assert_equal @second_account, @user.reload.current_account
  end
  
  test "should not switch to account that the user does not belong to" do
    @second_account = Account.create(:name => 'second account')
    post :switch, :id => @second_account
    assert_not_nil flash[:error]
    assert_equal @account, @user.reload.current_account
  end
end
