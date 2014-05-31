require 'spec_helper'

describe HealthCheckTemplateStepDataHelper do
  describe "#fake_form_for_health_check_template_step_data" do
    it "renders partial form with given child index" do
      child_index = 42
      helper.fake_form_for_health_check_template_step_data(child_index) do |form|
        expect(helper.render("/health_check_template_step_data/form", :f => form, :step_type => "visit")).to match(child_index.to_s)
      end
    end
  end
end
