require 'spec_helper'

describe HealthCheckTemplateStepsHelper do
  describe "#fake_form_for_health_check_template_step" do
    it "provides context for template step form" do
      child_index = 42
      helper.fake_form_for_health_check_template_step do |form|
        expect(helper.render "/health_check_template_steps/form", :f => form, :child_index => child_index).to match("health_check_template_steps_attributes_42_position")
      end
    end
  end
end
