class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.string :title
      t.text :text
      t.datetime :sent_at
      t.timestamps
    end
  end
end
