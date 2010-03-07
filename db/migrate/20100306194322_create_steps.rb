class CreateSteps < ActiveRecord::Migration
  def self.up
    create_table :steps do |t|
      t.integer :health_check_id
      t.string :type
      t.integer :position
      t.text :data
      t.timestamps
    end
  end

  def self.down
    drop_table :steps
  end
end
