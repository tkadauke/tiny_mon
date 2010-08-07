class CreateDeployments < ActiveRecord::Migration
  def self.up
    create_table :deployments do |t|
      t.integer :site_id
      t.string :revision
      t.timestamps
    end
    
    add_index :deployments, :site_id
  end

  def self.down
    drop_table :deployments
  end
end
