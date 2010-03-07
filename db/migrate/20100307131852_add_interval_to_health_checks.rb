class AddIntervalToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :interval, :integer
  end

  def self.down
    remove_column :health_checks, :interval
  end
end
