class CreateHealthCheckTemplateVariables < ActiveRecord::Migration
  def self.up
    create_table :health_check_template_variables do |t|
      t.integer :health_check_template_id
      t.string :name
      t.string :display_name
      t.string :description
      t.string :type
      t.boolean :required
      t.timestamps
    end
    
    add_index :health_check_template_variables, :health_check_template_id, :name => 'index_variables_on_health_check_template_id'
    
    remove_column :health_check_templates, :variables
  end

  def self.down
    add_column :health_check_templates, :variables, :text
    drop_table :health_check_template_variables
  end
end
