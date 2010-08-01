class CreateHealthCheckImports < ActiveRecord::Migration
  def self.up
    create_table :health_check_imports do |t|
      t.integer :account_id
      t.integer :site_id
      t.integer :user_id
      t.integer :health_check_template_id
      t.string :description
      t.text :csv_data
      t.timestamps
    end
  end

  def self.down
    drop_table :health_check_imports
  end
end
