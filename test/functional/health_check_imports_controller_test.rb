require 'test_helper'

class HealthCheckImportsControllerTest < ActionController::TestCase
  def setup
    @account = Account.create(:name => 'account')
    @user = @account.users.create(:full_name => 'John Doe', :email => 'john.doe@example.com', :password => '12345', :password_confirmation => '12345', :current_account => @account)
    @site = @account.sites.create(:name => 'example.com', :url => 'http://www.example.com')
    @health_check_template = @user.health_check_templates.create!(
      :name => 'Visit',
      :description => 'Simple Visit',
      :name_template => 'Visit {{domain}}',
      :interval => 60,
      :variables => [HealthCheckTemplateVariable.new(:name => 'domain', :display_name => 'Domain', :type => 'string')],
      :steps => [HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { :url => 'http://{{domain}}' })]
    )
    
    login_with @user
  end
  
  test "should get new" do
    get :new, :account_id => @account.id, :site_id => @site.permalink, :template => @health_check_template.id
    assert_response :success
  end
  
  test "should get preview" do
    csv = [['www.google.com'].to_csv, ['www.wikipedia.org'].to_csv].join
    
    assert_no_difference 'HealthCheck.count' do
      post :create, :account_id => @account.id, :site_id => @site.permalink, :commit => 'Preview',
           :health_check_import => { :health_check_template_id => @health_check_template.id, :csv_data => csv }
      assert_response :success
      assert_template 'new'
      assert assigns(:preview)
    end
  end
  
  test "should import" do
    csv = [['www.google.com'].to_csv, ['www.wikipedia.org'].to_csv].join
    
    assert_difference 'HealthCheck.count', 2 do
      post :create, :account_id => @account.id, :site_id => @site.permalink, :commit => 'Import',
           :health_check_import => { :health_check_template_id => @health_check_template.id, :csv_data => csv }
      assert_response :redirect
      assert ! assigns(:preview)
    end
  end
  
  test "should not import when import is invalid" do
    csv = [['www.google.com'].to_csv, ['www.wikipedia.org'].to_csv].join
    
    assert_no_difference 'HealthCheck.count', 2 do
      post :create, :account_id => @account.id, :site_id => @site.permalink, :commit => 'Import',
           :health_check_import => { :health_check_template_id => @health_check_template.id }
      assert_response :success
      assert_template 'new'
      assert ! assigns(:preview)
    end
  end
  
  test "should destroy import" do
    import = @site.health_check_imports.create!(:user => @user, :account => @account, :csv_data => '"foo"', :health_check_template => @health_check_template)
    assert_difference 'HealthCheckImport.count', -1 do
      delete :destroy, :account_id => @account.id, :site_id => @site.permalink, :id => import.id
      assert_response :redirect
    end
  end
  
  test "should destroy imported health checks" do
    import = @site.health_check_imports.create!(:user => @user, :account => @account, :csv_data => '"foo"', :health_check_template => @health_check_template)
    
    assert_equal 1, import.health_checks.count
    
    assert_difference 'HealthCheck.count', -1 do
      delete :destroy, :account_id => @account.id, :site_id => @site.permalink, :id => import.id
      assert_response :redirect
    end
  end
end
