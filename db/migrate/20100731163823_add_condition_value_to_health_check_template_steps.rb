class AddConditionValueToHealthCheckTemplateSteps < ActiveRecord::Migration
  def self.up
    add_column :health_check_template_steps, :condition_value, :string
  end

  def self.down
    remove_column :health_check_template_steps, :condition_value
  end
end
