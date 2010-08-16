class RmCheckRunsFromSecondTableMigration < ActiveRecord::Migration
  def self.up
    drop_table :check_runs_before_add_user_id_to_check_runs
  end

  def self.down
    create_table "check_runs_before_add_user_id_to_check_runs", :force => true do |t|
      t.integer  "health_check_id"
      t.string   "status"
      t.text     "log"
      t.string   "error_message"
      t.decimal  "started_at",      :precision => 20, :scale => 10
      t.decimal  "ended_at",        :precision => 20, :scale => 10
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "account_id"
      t.integer  "deployment_id"
    end
  end
end
