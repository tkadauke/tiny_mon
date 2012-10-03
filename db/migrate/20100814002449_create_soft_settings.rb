class CreateSoftSettings < ActiveRecord::Migration
  def self.up
    create_table :soft_settings do |t|
      t.integer :user_id
      t.string :key
      t.string :value
      t.timestamps
    end
  end

  def self.down
    drop_table :soft_settings
  end
end
