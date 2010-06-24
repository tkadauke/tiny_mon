class AddFullNameToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :full_name, :string
  end

  def self.down
    remove_column :users, :full_name
  end
end
