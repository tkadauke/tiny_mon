require 'lhm'

class RmCheckRunsFromSecondTableMigration < ActiveRecord::Migration
  def self.up
    drop_table :check_runs_before_add_user_id_to_check_runs if table_exists?(:check_runs_before_add_user_id_to_check_runs)
    Lhm.cleanup(true)
  end

  def self.down
  end
end
