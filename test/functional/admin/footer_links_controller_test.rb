require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::FooterLinksControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @user.role = 'admin'
    @user.save
    
    @footer_link = FooterLink.create(:text => 'wikipedia', :url => 'http://www.wikipedia.org')
    
    login_with @user
  end
  
  test "should show footer link index" do
    get :index
    assert_response :success
  end
  
  test "should show new" do
    get :new
    assert_response :success
  end
  
  test "should show edit" do
    get :edit, :id => @footer_link
    assert_response :success
  end
  
  test "should create footer link" do
    assert_difference 'FooterLink.count' do
      post :create, :footer_link => { :text => 'Google', :url => 'http://www.google.com' }
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
  
  test "should not create invalid footer link" do
    assert_no_difference 'FooterLink.count' do
      post :create, :footer_link => { :text => nil, :url => nil }
      assert_response :success
      assert_nil flash[:notice]
    end
  end
  
  test "should update footer link" do
    post :update, :id => @footer_link, :footer_link => { :text => 'changed name' }
    assert_response :redirect
    assert_not_nil flash[:notice]
    assert_equal 'changed name', @footer_link.reload.text
  end
  
  test "should not update invalid footer link" do
    post :update, :id => @footer_link, :footer_link => { :text => nil }
    assert_response :success
    assert_nil flash[:notice]
    assert_equal 'wikipedia', @footer_link.reload.text
  end
  
  test "should destroy footer link" do
    link = FooterLink.create(:text => 'Google', :url => 'http://www.google.com')
    
    assert_difference 'FooterLink.count', -1 do
      delete :destroy, :id => link
      assert_response :redirect
      assert_not_nil flash[:notice]
    end
  end
  
  test "should sort footer links" do
    link = FooterLink.create(:text => 'Google', :url => 'http://www.google.com')
    
    post :sort, :link => [link.id, @footer_link.id]
    
    assert_equal 0, link.reload.position
    assert_equal 1, @footer_link.reload.position
  end
end
