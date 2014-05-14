require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class AccountsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @user.set_role_for_account(@account, 'admin')
    
    login_with @user
  end
  
  test "should show account index" do
    get :index, :locale => 'en'
    assert_response :success
  end
  
  test "should show new" do
    get :new, :locale => 'en'
    assert_response :success
  end
  
  test "should show edit" do
    get :edit, :locale => 'en', :id => @account
    assert_response :success
  end
  
  test "should show account info" do
    get :show, :locale => 'en', :id => @account
    assert_response :success
  end
  
  test "should create account" do
    assert_difference 'Account.count' do
      assert_difference 'UserAccount.count' do
        post :create, :locale => 'en', :account => { :name => 'other account' }
        assert_response :redirect
        assert_not_nil flash[:notice]
      end
    end
  end
  
  test "should not create invalid account" do
    assert_no_difference 'Account.count' do
      assert_no_difference 'UserAccount.count' do
        post :create, :locale => 'en', :account => { :name => nil }
        assert_response :success
        assert_nil flash[:notice]
      end
    end
  end
  
  test "should update account" do
    post :update, :locale => 'en', :id => @account, :account => { :name => 'changed name' }
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_equal 'changed name', @account.reload.name
  end
  
  test "should not update account limits" do
    post :update, :locale => 'en', :id => @account, :account => { :maximum_check_runs_per_day => 1000 }
    assert_response :redirect
    assert_not_equal 1000, @account.reload.maximum_check_runs_per_day
  end
  
  test "should not update invalid account" do
    post :update, :locale => 'en', :id => @account, :account => { :name => nil }
    assert_response :success
    assert_nil flash[:notice]
    assert_equal 'account', @account.reload.name
  end
  
  test "should switch account" do
    @second_account = @user.accounts.create(:name => 'second account')
    post :switch, :locale => 'en', :id => @second_account
    assert_not_nil flash[:notice]
    assert_equal @second_account, @user.reload.current_account
  end
  
  test "should not switch to account that the user does not belong to" do
    @second_account = Account.create(:name => 'second account')
    post :switch, :locale => 'en', :id => @second_account
    assert_not_nil flash[:error]
    assert_equal @account, @user.reload.current_account
  end
end
