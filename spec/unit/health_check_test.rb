require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class HealthCheckTest < ActiveSupport::TestCase
  test "should figure out if check should run now" do
  end
  
  test "should create from template" do
    template = HealthCheckTemplate.new(
      :name_template => 'Visit {{target}}/foo',
      :interval => 1440,
      :steps => [HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { 'url' => '{{target}}/foo' })], 
      :variables => [HealthCheckTemplateVariable.new(:name => 'target', :type => 'string')]
    )
    data = { 'target' => 'http://www.example.com' }
    
    health_check = HealthCheck.new(:template => template, :template_data => data)
    health_check.get_info_from_template
    
    assert_equal 'Visit http://www.example.com/foo', health_check.name
    assert_equal 1440, health_check.interval
    assert health_check.steps.first.is_a?(VisitStep)
  end
  
  test "should validate template data" do
    template = HealthCheckTemplate.new(
      :name_template => 'Visit {{target}}/foo',
      :variables => [HealthCheckTemplateVariable.new(:name => 'target', :type => 'string', :required => true)],
      :interval => 1
    )
    data = { }
    
    health_check = HealthCheck.new(:template => template, :template_data => data, :site_id => 1)
    health_check.valid?
    
    assert ! health_check.template_data.errors.empty?
  end
  
  test "should calculate check runs per day" do
    assert_equal 1440, HealthCheck.new(:interval => 1).check_runs_per_day
    assert_equal 24, HealthCheck.new(:interval => 60).check_runs_per_day
    assert_equal 12, HealthCheck.new(:interval => 120).check_runs_per_day
  end
  
  test "should set next_check_at when health check gets enabled" do
    account = Account.create!(:name => 'TinyMon')
    site = Site.create!(:account => account, :name => 'TinyMon', :url => 'http://www.tinymon.org')
    check = HealthCheck.create!(:site => site, :name => 'Upcheck', :interval => 60, :enabled => false)
    
    assert_nil check.next_check_at
    
    check.update_attributes(:enabled => true)
    
    assert check.next_check_at < 2.minutes.from_now
  end
  
  test "should set next_check_at when health check interval is changed" do
    account = Account.create!(:name => 'TinyMon')
    site = Site.create!(:account => account, :name => 'TinyMon', :url => 'http://www.tinymon.org')
    check = HealthCheck.create!(:site => site, :name => 'Upcheck', :interval => 60, :enabled => true)
    
    check.update_attributes(:next_check_at => 1.hour.from_now)
    
    check.update_attributes(:interval => 5)
    
    assert check.next_check_at < 2.minutes.from_now
  end
end
