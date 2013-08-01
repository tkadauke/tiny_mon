require 'lhm'

module Lhm
  def self.cleanup(run = false)
    connection = Connection.new(adapter)
    
    lhm_tables = connection.select_values("show tables").select do |name|
      name =~ /^lhm(a|n)_/
    end
    return true if lhm_tables.empty?
    if run
      lhm_tables.each do |table|
        connection.execute("drop table #{table}")
      end
      true
    else
      puts "Existing LHM backup tables: #{lhm_tables.join(", ")}."
      puts "Run Lhm.cleanup(true) to drop them all."
      false
    end
  end
end

class RmCheckRunsFromFirstTableMigration < ActiveRecord::Migration
  def self.up
    drop_table :check_runs_before_add_deployment_id_to_check_runs if table_exists?(:check_runs_before_add_deployment_id_to_check_runs)
    Lhm.cleanup(true)
  end

  def self.down
  end
end
