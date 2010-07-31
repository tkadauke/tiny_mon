module HealthCheckTemplateStepDataHelper
  def fake_form_for_health_check_template_step_data(step_index, &block)
    @health_check_template = HealthCheckTemplate.new
    step = @health_check_template.steps.build
    builder = ActionView::Helpers::FormBuilder.new(:health_check_template, @health_check_template, @template, {}, proc {} )
    builder.fields_for(:steps, :child_index => step_index) do |steps|
      steps.fields_for(:step_data, &block)
    end
  end
end
