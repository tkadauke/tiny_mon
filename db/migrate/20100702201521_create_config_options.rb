class CreateConfigOptions < ActiveRecord::Migration
  def self.up
    create_table :config_options do |t|
      t.integer :user_id
      t.string :key
      t.text :value
      t.timestamps
    end
  end

  def self.down
    drop_table :config_options
  end
end
