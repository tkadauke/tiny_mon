class AddRoleToUserAccounts < ActiveRecord::Migration
  def self.up
    add_column :user_accounts, :role, :string, :default => 'user'
  end

  def self.down
    remove_column :user_accounts, :role
  end
end
