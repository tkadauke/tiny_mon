require 'test_helper'

class HealthCheckTemplateTest < ActiveSupport::TestCase
  test "should evaluate name" do
    template = HealthCheckTemplate.new(:name_template => "{{thing}} test", :variables => ['thing' => { 'name' => 'thing', 'type' => 'string' }].to_yaml)
    data = HealthCheckTemplateData.new(:thing => 'foo')
    assert_equal 'foo test', template.evaluate_name(data)
  end
  
  test "should evaluate description" do
    template = HealthCheckTemplate.new(:description_template => "This tests {{thing}}", :variables => ['thing' => { 'name' => 'thing', 'type' => 'string' }].to_yaml)
    data = HealthCheckTemplateData.new(:thing => 'foo')
    assert_equal 'This tests foo', template.evaluate_description(data)
  end
  
  test "should evaluate steps" do
    template = HealthCheckTemplate.new(:steps_template => ['visit' => { 'url' => '{{target}}/foo' }].to_yaml, :variables => ['target' => { 'name' => 'target', 'type' => 'string' }].to_yaml)
    data = HealthCheckTemplateData.new(:target => 'http://www.example.com')
    steps = template.evaluate_steps(data)
    assert steps.first.is_a?(VisitStep)
    assert_equal 'http://www.example.com/foo', steps.first.url
  end
end
