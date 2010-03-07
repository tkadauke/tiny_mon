class CreateHealthChecks < ActiveRecord::Migration
  def self.up
    create_table :health_checks do |t|
      t.integer :site_id
      t.string :name
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :health_checks
  end
end
