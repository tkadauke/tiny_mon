class AddCheckTimestampsToHealthChecks < ActiveRecord::Migration
  def self.up
    add_column :health_checks, :last_checked_at, :datetime
    add_column :health_checks, :next_check_at, :datetime
    
    add_index :health_checks, :next_check_at
    
    HealthCheck.reset_column_information
    HealthCheck.all.each do |check|
      check.update_attribute(:next_check_at, Time.now + rand(check.interval.minutes))
    end
  end

  def self.down
    remove_column :health_checks, :next_check_at
    remove_column :health_checks, :last_checked_at
  end
end
