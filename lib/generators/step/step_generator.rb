class StepGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)
  argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"
  check_class_collision suffix: "Controller"
  
  def create_step_files
    template 'step.rb',       File.join('app/steps', "#{file_name}_step.rb")
    template 'step.html.erb', File.join('app/views/steps', "_#{file_name}_step.html.erb")
    template 'form.html.erb', File.join('app/views/steps', "_#{file_name}_step_form.html.erb")
    template 'unit_test.rb',  File.join('test/unit', "#{file_name}_step_test.rb")
  end

protected
  def banner
    "Usage: #{$0} #{spec.name} StepName  [field:type, field:type]"
  end
end
