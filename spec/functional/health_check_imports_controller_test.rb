require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
  
  test "should choose template for site" do
    get :new, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink
    assert_response :success
  end
  
  test "should choose template for account" do
    get :new, :locale => 'en'
    assert_response :success
  end
  
  test "should filter templates by user" do
    get :new, :locale => 'en', :filter => 'mine'
    assert_response :success
  end
  
  test "should filter templates by account" do
    get :new, :locale => 'en', :filter => 'account'
    assert_response :success
  end
  
  test "should show public templates" do
    get :new, :locale => 'en', :filter => 'public'
    assert_response :success
  end
  
  test "should get new for site" do
    get :new, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :template => @health_check_template.id
    assert_response :success
  end
  
  test "should get new for account" do
    get :new, :locale => 'en', :template => @health_check_template.id
    assert_response :success
  end
  
  test "should get preview for site" do
    csv = [['www.google.com'].to_csv, ['www.wikipedia.org'].to_csv].join
    
    assert_no_difference 'HealthCheck.count' do
      post :create, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :commit => 'Preview',
           :health_check_import => { :health_check_template_id => @health_check_template.id, :csv_data => csv }
      assert_response :success
      assert_template 'new'
      assert assigns(:preview)
    end
  end
  
  test "should get preview for account" do
    csv = [['first_site', 'Google', 'http://www.google.com'].to_csv, ['second_site', 'Wikipedia', 'http://www.wikipedia.org'].to_csv].join
    
    assert_no_difference 'HealthCheck.count' do
      post :create, :locale => 'en', :commit => 'Preview', :health_check_import => { :health_check_template_id => @health_check_template.id, :csv_data => csv }
      assert_response :success
      assert_template 'new'
      assert assigns(:preview)
    end
  end
  
  test "should import for site" do
    csv = [['www.google.com'].to_csv, ['www.wikipedia.org'].to_csv].join
    
    assert_difference 'HealthCheck.count', 2 do
      post :create, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :commit => 'Import',
           :health_check_import => { :health_check_template_id => @health_check_template.id, :csv_data => csv }
      assert_response :redirect
      assert ! assigns(:preview)
    end
  end
  
  test "should import for account" do
    csv = [['first_site', 'Google', 'http://www.google.com'].to_csv, ['second_site', 'Wikipedia', 'http://www.wikipedia.org'].to_csv].join
    
    assert_difference 'Site.count', 2 do
      assert_difference 'HealthCheck.count', 2 do
        post :create, :locale => 'en', :commit => 'Import', :health_check_import => { :health_check_template_id => @health_check_template.id, :csv_data => csv }
        assert_response :redirect
        assert ! assigns(:preview)
      end
    end
  end
  
  test "should not import for site when import is invalid" do
    csv = [['www.google.com'].to_csv, ['www.wikipedia.org'].to_csv].join
    
    assert_no_difference 'HealthCheck.count', 2 do
      post :create, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :commit => 'Import',
           :health_check_import => { :health_check_template_id => @health_check_template.id }
      assert_response :success
      assert_template 'new'
      assert ! assigns(:preview)
    end
  end
  
  test "should not import for account when import is invalid" do
    csv = [['first_site', 'Google', 'http://www.google.com'].to_csv, ['second_site', 'Wikipedia', 'http://www.wikipedia.org'].to_csv].join
    
    assert_no_difference 'HealthCheck.count', 2 do
      post :create, :locale => 'en', :commit => 'Import', :health_check_import => { :health_check_template_id => @health_check_template.id }
      assert_response :success
      assert_template 'new'
      assert ! assigns(:preview)
    end
  end
  
  test "should destroy import for site" do
    import = @site.health_check_imports.create!(:user => @user, :account => @account, :csv_data => '"foo"', :health_check_template => @health_check_template)
    assert_difference 'HealthCheckImport.count', -1 do
      delete :destroy, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :id => import.id
      assert_response :redirect
    end
  end
  
  test "should destroy import for account" do
    import = @site.health_check_imports.create!(:user => @user, :account => @account, :csv_data => '"foo"', :health_check_template => @health_check_template)
    assert_difference 'HealthCheckImport.count', -1 do
      delete :destroy, :locale => 'en', :id => import.id
      assert_response :redirect
    end
  end
  
  test "should destroy imported health checks for site" do
    import = @site.health_check_imports.create!(:user => @user, :account => @account, :csv_data => '"foo"', :health_check_template => @health_check_template)
    
    assert_equal 1, import.health_checks.count
    
    assert_difference 'HealthCheck.count', -1 do
      delete :destroy, :locale => 'en', :account_id => @account.id, :site_id => @site.permalink, :id => import.id
      assert_response :redirect
    end
  end
end
