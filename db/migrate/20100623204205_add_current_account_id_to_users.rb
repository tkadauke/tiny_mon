class AddCurrentAccountIdToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :current_account_id, :integer
  end

  def self.down
    remove_column :users, :current_account_id
  end
end
