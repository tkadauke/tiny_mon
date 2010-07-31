class AddPositionToHealthCheckTemplateVariables < ActiveRecord::Migration
  def self.up
    add_column :health_check_template_variables, :position, :integer
  end

  def self.down
    remove_column :health_check_template_variables, :position
  end
end
