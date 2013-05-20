require 'lhm'

class AddDeploymentIdToCheckRuns < ActiveRecord::Migration
  def self.up
    Lhm.change_table :check_runs do |m|
      m.add_column :deployment_id, :integer
      m.add_index [:deployment_id]
    end
  end

  def self.down
    Lhm.change_table :check_runs do |m|
      m.remove_index [:deployment_id]
      m.remove_column :deployment_id
    end
  end
end
