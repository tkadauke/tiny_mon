require 'lhm'

class AddUserIdToCheckRuns < ActiveRecord::Migration
  def self.up
    Lhm.change_table :check_runs do |m|
      m.add_column :user_id, :integer
    end
  end

  def self.down
    Lhm.change_table :check_runs do |m|
      m.remove_column :user_id
    end
  end
end
