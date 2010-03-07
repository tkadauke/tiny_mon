class AddEnabledToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :enabled, :boolean, :default => false
    
    add_index :health_checks, :enabled
  end

  def self.down
    remove_column :health_checks, :enabled
  end
end
