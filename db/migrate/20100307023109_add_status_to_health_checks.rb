class AddStatusToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :status, :string
  end

  def self.down
    remove_column :health_checks, :status
  end
end
