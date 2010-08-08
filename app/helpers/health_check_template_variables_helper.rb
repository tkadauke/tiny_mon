module HealthCheckTemplateVariablesHelper
  def fake_form_for_health_check_template_variable(&block)
    @health_check_template = HealthCheckTemplate.new
    @health_check_template.variables.build
    fields_for(@health_check_template, &block)
  end
end
