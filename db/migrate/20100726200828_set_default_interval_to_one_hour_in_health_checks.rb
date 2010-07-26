class SetDefaultIntervalToOneHourInHealthChecks < ActiveRecord::Migration
  def self.up
    change_column :health_checks, :interval, :integer, :default => 60
  end

  def self.down
    change_column :health_checks, :interval, :integer, :default => 1
  end
end
