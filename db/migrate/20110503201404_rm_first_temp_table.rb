class RmFirstTempTable < ActiveRecord::Migration
  def self.up
    drop_table :check_runs_before_add_index_on_check_runs
  end

  def self.down
  end
end
