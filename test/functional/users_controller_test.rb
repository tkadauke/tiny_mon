require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UsersControllerTest < ActionController::TestCase
  test "should redirect to accounts path on index" do
    @account = Account.create(:name => 'account')
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    login_with john

    get :index
    assert_response :redirect
    assert_redirected_to account_path(@account)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create user" do
    assert_difference 'User.count' do
      post :create, :user => { :full_name => "John Doe", :password => "12345", :password_confirmation => "12345", :email => "john@doe.com" }
    end
    
    assert_redirected_to root_path
  end
  
  test "should not create invalid user" do
    assert_no_difference 'User.count' do
      post :create, :user => { :full_name => nil, :password => "54321", :password_confirmation => "12345", :email => "john@doe.com" }
    end
    
    assert_response :success
  end
  
  test "should show user" do
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    login_with john
    
    get :show, :id => john.id
    assert_response :success
  end

  test "should get edit" do
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    login_with john

    get :edit, :id => john.id
    assert_response :success
  end

  test "should update user" do
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    login_with john

    put :update, :id => john.id, :user => { }
    assert_redirected_to root_path
  end
  
  test "should not update invalid user" do
    john = User.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345')
    login_with john

    put :update, :id => john.id, :user => { :full_name => nil }
    assert_response :success
  end
  
  test "should register additional user for account" do
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    
    login_with @user
    
    assert_difference 'User.count' do
      assert_difference 'UserAccount.count' do
        post :create, :user => { :full_name => "Jane Doe", :password => "12345", :password_confirmation => "12345", :email => "jane@doe.com" }
        assert_response :redirect
      end
    end
  end
end
