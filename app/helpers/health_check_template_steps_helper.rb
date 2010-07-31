module HealthCheckTemplateStepsHelper
  def fake_form_for_health_check_template_step(&block)
    @health_check_template = HealthCheckTemplate.new
    @health_check_template.steps.build
    yield ActionView::Helpers::FormBuilder.new(:health_check_template, @health_check_template, @template, {}, proc {} )
  end
end
