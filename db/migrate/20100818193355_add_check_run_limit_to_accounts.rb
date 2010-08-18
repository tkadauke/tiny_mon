class AddCheckRunLimitToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :maximum_check_runs_per_day, :integer, :default => 100
    add_column :accounts, :check_runs_per_day, :integer, :default => 0
    
    Account.reset_column_information
    Account.update_all 'maximum_check_runs_per_day = 0'
    Account.all.each do |account|
      account.update_check_runs_per_day
    end
  end

  def self.down
    remove_column :accounts, :check_runs_per_day
    remove_column :accounts, :maximum_check_runs_per_day
  end
end
