require 'test_helper'

class StepsControllerTest < ActionController::TestCase
  def setup
    @site = Site.create(:name => 'example.com')
    @health_check = @site.health_checks.create(:name => 'Home Page')
  end
  
  test "should show index" do
    step = @health_check.steps.create
    get :index, , :site_id => @site, :health_check_id => @health_check
    assert_response :success
  end
  
  test "should show new" do
    xhr :get, :new, :site_id => @site, :health_check_id => @health_check, :type => 'visit'
    assert_response :success
    assert assigns(:step).is_a?(VisitStep)
  end
  
  test "should create step" do
    assert_redirected_back do
      assert_difference 'Step.count' do
        post :create, :site_id => @site, :health_check_id => @health_check, :type => 'visit', :visit_step => { :url => '/' }
        assert assigns(:step).is_a?(VisitStep)
      end
    end
  end
  
  test "should delete step" do
    step = @health_check.steps.create
    assert_difference 'Step.count', -1 do
      assert_redirected_back do
        delete :destroy, :site_id => @site, :health_check_id => @health_check, :id => step
      end
    end
  end
end
