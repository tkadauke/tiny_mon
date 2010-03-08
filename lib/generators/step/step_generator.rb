class StepGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions "#{class_name}Step", "#{class_name}StepTest"

      # Model, test, and view directories.
      m.directory 'app/models'
      m.directory 'app/views/steps'
      m.directory 'test/unit'

      # Model class, unit test and views
      m.template 'step.rb',       File.join('app/models', "#{file_name}_step.rb")
      m.template 'step.html.erb', File.join('app/views/steps', "_#{file_name}_step.html.erb")
      m.template 'form.html.erb', File.join('app/views/steps', "_#{file_name}_step_form.html.erb")
      m.template 'unit_test.rb',  File.join('test/unit', "#{file_name}_step_test.rb")
    end
  end

protected
  def banner
    "Usage: #{$0} #{spec.name} StepName  [field:type, field:type]"
  end
end
