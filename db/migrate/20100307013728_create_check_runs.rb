class CreateCheckRuns < ActiveRecord::Migration
  def self.up
    create_table :check_runs do |t|
      t.integer :health_check_id
      t.string :status
      t.text :log
      t.string :error_message
      t.decimal :started_at
      t.decimal :ended_at
      t.timestamps
    end
  end

  def self.down
    drop_table :check_runs
  end
end
