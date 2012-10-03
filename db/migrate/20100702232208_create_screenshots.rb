class CreateScreenshots < ActiveRecord::Migration
  def self.up
    create_table :screenshots do |t|
      t.integer :check_run_id
      t.string :url
      t.string :checksum
      t.string :format
      t.timestamps
    end
    
    add_index :screenshots, :check_run_id
  end

  def self.down
    drop_table :screenshots
  end
end
