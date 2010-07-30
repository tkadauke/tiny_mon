require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HealthCheckTest < ActiveSupport::TestCase
  test "should figure out if check should run now" do
  end
  
  test "should create from template" do
    template = HealthCheckTemplate.new(
      :name_template => 'Visit {{target}}/foo',
      :interval => 1440,
      :steps_template => ['visit' => { 'url' => '{{target}}/foo' }].to_yaml, 
      :variables => ['target' => { 'name' => 'target', 'type' => 'string' }].to_yaml
    )
    data = { 'target' => 'http://www.example.com' }
    
    health_check = HealthCheck.new(:template => template, :template_data => data)
    health_check.get_info_from_template
    
    assert_equal 'Visit http://www.example.com/foo', health_check.name
    assert_equal 1440, health_check.interval
    assert health_check.steps.first.is_a?(VisitStep)
  end
end
