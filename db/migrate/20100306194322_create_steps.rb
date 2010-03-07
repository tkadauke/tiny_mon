class CreateSteps < ActiveRecord::Migration
  def self.up
    create_table :steps do |t|
      t.integer :health_check_id
      t.string :type
      t.integer :position
      t.text :data
      t.timestamps
    end
    
    add_index :steps, :health_check_id
    add_index :steps, :position
  end

  def self.down
    drop_table :steps
  end
end
