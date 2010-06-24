class CreateUserAccounts < ActiveRecord::Migration
  def self.up
    create_table :user_accounts do |t|
      t.integer :user_id
      t.integer :account_id
      t.timestamps
    end
  end

  def self.down
    drop_table :user_accounts
  end
end
