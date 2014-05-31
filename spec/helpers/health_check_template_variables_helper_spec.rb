require 'spec_helper'

describe HealthCheckTemplateVariablesHelper do
  describe "#fake_form_for_health_check_template_variable" do
    it "provides context for template variable form" do
      child_index = 42
      helper.fake_form_for_health_check_template_variable do |form|
        expect(helper.render "/health_check_template_variables/form", :f => form, :child_index => child_index).to match("health_check_template_variables_attributes_42_position")
      end
    end
  end
end
