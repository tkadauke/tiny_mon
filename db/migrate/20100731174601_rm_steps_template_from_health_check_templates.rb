class RmStepsTemplateFromHealthCheckTemplates < ActiveRecord::Migration
  def self.up
    remove_column :health_check_templates, :steps_template
  end

  def self.down
    add_column :health_check_templates, :steps_template, :text
  end
end
