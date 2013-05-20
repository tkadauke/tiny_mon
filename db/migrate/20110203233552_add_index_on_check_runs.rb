require 'lhm'

class AddIndexOnCheckRuns < ActiveRecord::Migration
  def self.up
    Lhm.change_table :check_runs, :atomic_switch => true do |m|
      m.add_index [:health_check_id, :created_at]
    end
  end

  def self.down
    Lhm.change_table :check_runs, :atomic_switch => true do |m|
      m.remove_index [:health_check_id, :created_at]
    end
  end
end
