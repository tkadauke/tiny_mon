require 'lhm'

class AddLastResponseToCheckRuns < ActiveRecord::Migration
  def self.up
    Lhm.change_table :check_runs, :atomic_switch => true do |m|
      m.add_column :last_response, :text
    end
  end

  def self.down
    Lhm.change_table :check_runs, :atomic_switch => true do |m|
      m.remove_column :last_response
    end
  end
end
