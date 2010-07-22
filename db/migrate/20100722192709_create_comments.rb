class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :check_run_id
      t.integer :user_id
      t.string :title
      t.text :text
      t.timestamps
    end
    
    add_index :comments, [:check_run_id, :created_at]
    add_index :comments, :user_id
  end

  def self.down
    drop_table :comments
  end
end
