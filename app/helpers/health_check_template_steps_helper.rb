module HealthCheckTemplateStepsHelper
  def fake_form_for_health_check_template_step(&block)
    @health_check_template = HealthCheckTemplate.new
    @health_check_template.steps.build
    fields_for(@health_check_template, &block)
  end
end
