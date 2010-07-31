class CreateHealthCheckTemplateSteps < ActiveRecord::Migration
  def self.up
    create_table :health_check_template_steps do |t|
      t.integer :health_check_template_id
      t.integer :position
      t.string :condition
      t.string :condition_parameter
      t.string :step_type
      t.text :step_data_hash
      t.timestamps
    end
    
    add_index :health_check_template_steps, :health_check_template_id, :name => 'index_steps_on_health_check_template_id'
  end

  def self.down
    drop_table :health_check_template_steps
  end
end
