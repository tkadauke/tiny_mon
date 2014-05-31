FactoryGirl.define do
  factory :health_check_template do
    name "Visit"
    description "Simple Visit"
    name_template "Visit {{domain}}"
    interval 60
    variables { [HealthCheckTemplateVariable.new(:name => "domain", :display_name => "Domain", :type => "string")] }
    steps { [HealthCheckTemplateStep.new(:step_type => "visit", :step_data => { :url => "http://{{domain}}" })] }
  end
end
