class CreateHealthChecks < ActiveRecord::Migration
  def self.up
    create_table :health_checks do |t|
      t.integer :site_id
      t.string :name
      t.text :description
      t.timestamps
    end
    
    add_index :health_checks, :site_id
    add_index :health_checks, :name
  end

  def self.down
    drop_table :health_checks
  end
end
