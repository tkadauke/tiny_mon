# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100307133156) do

  create_table "check_runs", :force => true do |t|
    t.integer  "health_check_id"
    t.string   "status"
    t.text     "log"
    t.string   "error_message"
    t.integer  "started_at",      :limit => 10, :precision => 10, :scale => 0
    t.integer  "ended_at",        :limit => 10, :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "check_runs", ["created_at"], :name => "index_check_runs_on_created_at"
  add_index "check_runs", ["health_check_id"], :name => "index_check_runs_on_health_check_id"

  create_table "health_checks", :force => true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "interval"
    t.boolean  "enabled",     :default => false
  end

  add_index "health_checks", ["enabled"], :name => "index_health_checks_on_enabled"
  add_index "health_checks", ["name"], :name => "index_health_checks_on_name"
  add_index "health_checks", ["site_id"], :name => "index_health_checks_on_site_id"
  add_index "health_checks", ["status"], :name => "index_health_checks_on_status"

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sites", ["name"], :name => "index_sites_on_name"

  create_table "steps", :force => true do |t|
    t.integer  "health_check_id"
    t.string   "type"
    t.integer  "position"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "steps", ["health_check_id"], :name => "index_steps_on_health_check_id"
  add_index "steps", ["position"], :name => "index_steps_on_position"

end
