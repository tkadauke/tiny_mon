class AddAccountIdToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :account_id, :integer
  end

  def self.down
    remove_column :sites, :account_id
  end
end
