class AddAccountIdToCheckRuns < ActiveRecord::Migration
  def self.up
    add_column :check_runs, :account_id, :integer
    
    add_index :check_runs, :account_id
    add_index :check_runs, [:account_id, :created_at]
    
    CheckRun.reset_column_information
    CheckRun.find(:all, :include => { :health_check => :site }).each do |check_run|
      check_run.update_attribute(:account_id, check_run.health_check.site.account_id) rescue nil
    end
  end

  def self.down
    remove_column :check_runs, :account_id
  end
end
