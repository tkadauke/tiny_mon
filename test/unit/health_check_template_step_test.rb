require 'test_helper'

class HealthCheckTemplateStepTest < ActiveSupport::TestCase
  test "should build step" do
    template_step = HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { :url => 'http://{{domain}}' })
    data = HealthCheckTemplateData.new('domain' => 'www.example.com')
    
    step = template_step.build_steps(data)
    assert step.is_a?(VisitStep)
    assert_equal 'http://www.example.com', step.url
  end
  
  test "should not build step if variable set condition is not met" do
    template_step = HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { :url => 'http://{{domain}}' }, :condition => 'if_variable_set', :condition_parameter => 'foobar')
    data = HealthCheckTemplateData.new('domain' => 'www.example.com')
    
    assert_nil template_step.build_steps(data)
  end
  
  test "should not build step if variable unset condition is not met" do
    template_step = HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { :url => 'http://{{domain}}' }, :condition => 'if_variable_unset', :condition_parameter => 'domain')
    data = HealthCheckTemplateData.new('domain' => 'www.example.com')
    
    assert_nil template_step.build_steps(data)
  end
  
  test "should not build step if variable equals condition is not met" do
    template_step = HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { :url => 'http://{{domain}}' }, :condition => 'if_variable_equals', :condition_parameter => 'domain', :condition_value => 'www.google.com')
    data = HealthCheckTemplateData.new('domain' => 'www.example.com')
    
    assert_nil template_step.build_steps(data)
  end
  
  test "should not build step if variable not equal condition is not met" do
    template_step = HealthCheckTemplateStep.new(:step_type => 'visit', :step_data => { :url => 'http://{{domain}}' }, :condition => 'if_variable_not_equal', :condition_parameter => 'domain', :condition_value => 'www.example.com')
    data = HealthCheckTemplateData.new('domain' => 'www.example.com')
    
    assert_nil template_step.build_steps(data)
  end
end
