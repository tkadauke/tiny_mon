class CreateHealthCheckTemplates < ActiveRecord::Migration
  def self.up
    create_table :health_check_templates do |t|
      t.integer :user_id
      t.boolean :public, :default => false
      t.string :name
      t.text :description
      t.text :variables
      t.string :name_template
      t.text :description_template
      t.integer :interval
      t.text :steps_template
      t.timestamps
    end
  end

  def self.down
    drop_table :health_check_templates
  end
end
