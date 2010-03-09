require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class StartControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert assigns(:check_runs)
  end
  
  test "should update index" do
    xhr :get, :index
    assert_response :success
    assert assigns(:check_runs)
  end
end
