require 'test_helper'

class UsersControllerTest < ActionController::TestCase
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
end
