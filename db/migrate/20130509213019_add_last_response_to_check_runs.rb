require 'lhm'

class AddLastResponseToCheckRuns < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      Lhm.change_table :check_runs, :atomic_switch => true do |m|
        m.add_column :last_response, :text
      end
    else
      add_column :check_runs, :last_response, :text
    end
  end

  def self.down
    if ActiveRecord::Base.connection.adapter_name == 'MySQL'
      Lhm.change_table :check_runs, :atomic_switch => true do |m|
        m.remove_column :last_response
      end
    else
      remove_column :check_runs, :last_response
    end
  end
end
