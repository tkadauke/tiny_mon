class CreateFooterLinks < ActiveRecord::Migration
  def self.up
    create_table :footer_links do |t|
      t.string :text
      t.string :url
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :footer_links
  end
end
