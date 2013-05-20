require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::BroadcastsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @user.role = 'admin'
    @user.save
    
    @broadcast = Broadcast.create(:title => 'Hello', :text => 'World')
    
    login_with @user
  end
  
  test "should show broadcast index" do
    get :index, :locale => 'en'
    assert_response :success
  end
  
  test "should show new" do
    get :new, :locale => 'en'
    assert_response :success
  end
  
  test "should show broadcast" do
    get :show, :locale => 'en', :id => @broadcast
    assert_response :success
  end
  
  test "should show edit" do
    get :edit, :locale => 'en', :id => @broadcast
    assert_response :success
  end
  
  test "should create broadcast" do
    assert_difference 'Broadcast.count' do
      post :create, :locale => 'en', :broadcast => { :title => 'Hello', :text => 'World' }
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
  
  test "should not create invalid broadcast" do
    assert_no_difference 'Broadcast.count' do
      post :create, :locale => 'en', :broadcast => { :title => nil, :text => nil }
      assert_response :success
      assert_nil flash[:notice]
    end
  end
  
  test "should update broadcast" do
    post :update, :locale => 'en', :id => @broadcast, :broadcast => { :text => 'changed text' }
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_equal 'changed text', @broadcast.reload.text
  end
  
  test "should not update invalid broadcast" do
    post :update, :locale => 'en', :id => @broadcast, :broadcast => { :text => nil }
    assert_response :success
    assert_nil flash[:notice]
    assert_equal 'World', @broadcast.reload.text
  end
  
  test "should destroy broadcast" do
    broadcast = Broadcast.create(:title => 'Hello', :text => 'World')
    
    assert_difference 'Broadcast.count', -1 do
      delete :destroy, :locale => 'en', :id => broadcast
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
  
  test "should deliver broadcast" do
    broadcast = Broadcast.create(:title => 'Hello', :text => 'World')
    
    assert_nil broadcast.sent_at
    
    post :deliver, :locale => 'en', :id => broadcast
    
    assert_not_nil broadcast.reload.sent_at
  end
end
