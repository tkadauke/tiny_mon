class AddAccountIdToCheckRuns < ActiveRecord::Migration
  def self.up
    add_column :check_runs, :account_id, :integer
    
    add_index :check_runs, :account_id
    add_index :check_runs, [:account_id, :created_at]
    
    CheckRun.reset_column_information
    
    Account.find(:all).each do |account|
      result = ActiveRecord::Base.connection.select_all("SELECT `check_runs`.`id` FROM `check_runs` LEFT OUTER JOIN `health_checks` ON `health_checks`.id = `check_runs`.health_check_id LEFT OUTER JOIN `sites` ON `sites`.id = `health_checks`.site_id WHERE (sites.account_id = #{account.id})")
      check_run_ids = result.collect {|p|p.values}.flatten
      CheckRun.update_all "account_id = #{account.id}", ["id in (?)", check_run_ids]
    end
  end

  def self.down
    remove_column :check_runs, :account_id
  end
end
