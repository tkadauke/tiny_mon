# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 201340618213019) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "maximum_check_runs_per_day", default: 100
    t.integer  "check_runs_per_day",         default: 0
  end

  create_table "broadcasts", force: true do |t|
    t.string   "title"
    t.text     "text"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "check_runs", force: true do |t|
    t.integer  "health_check_id"
    t.string   "status"
    t.text     "log"
    t.string   "error_message"
    t.decimal  "started_at",               precision: 20, scale: 10
    t.decimal  "ended_at",                 precision: 20, scale: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.integer  "deployment_id"
    t.integer  "user_id"
    t.text     "last_response"
    t.boolean  "always_send_notification"
  end

  add_index "check_runs", ["account_id", "created_at"], name: "index_check_runs_on_account_id_and_created_at", using: :btree
  add_index "check_runs", ["account_id"], name: "index_check_runs_on_account_id", using: :btree
  add_index "check_runs", ["created_at"], name: "index_check_runs_on_created_at", using: :btree
  add_index "check_runs", ["deployment_id"], name: "index_new_check_runs_on_deployment_id", using: :btree
  add_index "check_runs", ["health_check_id", "created_at"], name: "index_new_check_runs_on_health_check_id_and_created_at", using: :btree
  add_index "check_runs", ["health_check_id"], name: "index_check_runs_on_health_check_id", using: :btree

  create_table "comments", force: true do |t|
    t.integer  "check_run_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "comments", ["account_id", "created_at"], name: "index_comments_on_account_id_and_created_at", using: :btree
  add_index "comments", ["account_id"], name: "index_comments_on_account_id", using: :btree
  add_index "comments", ["check_run_id", "created_at"], name: "index_comments_on_check_run_id_and_created_at", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "config_options", force: true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deployments", force: true do |t|
    t.integer  "site_id"
    t.string   "revision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deployments", ["site_id"], name: "index_deployments_on_site_id", using: :btree

  create_table "footer_links", force: true do |t|
    t.string   "text"
    t.string   "url"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "health_check_imports", force: true do |t|
    t.integer  "account_id"
    t.integer  "site_id"
    t.integer  "user_id"
    t.integer  "health_check_template_id"
    t.string   "description"
    t.text     "csv_data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "health_check_template_steps", force: true do |t|
    t.integer  "health_check_template_id"
    t.integer  "position"
    t.string   "condition"
    t.string   "condition_parameter"
    t.string   "step_type"
    t.text     "step_data_hash"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "condition_value"
  end

  add_index "health_check_template_steps", ["health_check_template_id"], name: "index_steps_on_health_check_template_id", using: :btree

  create_table "health_check_template_variables", force: true do |t|
    t.integer  "health_check_template_id"
    t.string   "name"
    t.string   "display_name"
    t.string   "description"
    t.string   "type"
    t.boolean  "required"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "health_check_template_variables", ["health_check_template_id"], name: "index_variables_on_health_check_template_id", using: :btree

  create_table "health_check_templates", force: true do |t|
    t.integer  "user_id"
    t.boolean  "public",               default: false
    t.string   "name"
    t.text     "description"
    t.string   "name_template"
    t.text     "description_template"
    t.integer  "interval"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "health_check_templates", ["account_id"], name: "index_health_check_templates_on_account_id", using: :btree

  create_table "health_checks", force: true do |t|
    t.integer  "site_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.integer  "interval",                 default: 60
    t.boolean  "enabled",                  default: false
    t.string   "permalink"
    t.datetime "last_checked_at"
    t.datetime "next_check_at"
    t.integer  "health_check_import_id"
    t.integer  "weather"
    t.boolean  "always_send_notification"
  end

  add_index "health_checks", ["enabled"], name: "index_health_checks_on_enabled", using: :btree
  add_index "health_checks", ["name"], name: "index_health_checks_on_name", using: :btree
  add_index "health_checks", ["next_check_at"], name: "index_health_checks_on_next_check_at", using: :btree
  add_index "health_checks", ["site_id"], name: "index_health_checks_on_site_id", using: :btree
  add_index "health_checks", ["status"], name: "index_health_checks_on_status", using: :btree

  create_table "screenshot_comparisons", force: true do |t|
    t.integer  "check_run_id"
    t.integer  "first_screenshot_id"
    t.integer  "second_screenshot_id"
    t.string   "checksum"
    t.float    "distance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "screenshots", force: true do |t|
    t.integer  "check_run_id"
    t.string   "url"
    t.string   "checksum"
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step_id"
  end

  add_index "screenshots", ["check_run_id"], name: "index_screenshots_on_check_run_id", using: :btree
  add_index "screenshots", ["step_id", "created_at"], name: "index_screenshots_on_step_id_and_created_at", using: :btree

  create_table "sites", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.integer  "account_id"
    t.string   "deployment_token"
  end

  add_index "sites", ["deployment_token"], name: "index_sites_on_deployment_token", using: :btree
  add_index "sites", ["name"], name: "index_sites_on_name", using: :btree

  create_table "soft_settings", force: true do |t|
    t.integer  "user_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", force: true do |t|
    t.integer  "health_check_id"
    t.string   "type"
    t.integer  "position"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "steps", ["health_check_id"], name: "index_steps_on_health_check_id", using: :btree
  add_index "steps", ["position"], name: "index_steps_on_position", using: :btree

  create_table "user_accounts", force: true do |t|
    t.integer  "user_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",       default: "user"
  end

  create_table "users", force: true do |t|
    t.string   "email",                           null: false
    t.string   "crypted_password",                null: false
    t.string   "password_salt",                   null: false
    t.string   "persistence_token",               null: false
    t.string   "single_access_token",             null: false
    t.string   "perishable_token",                null: false
    t.integer  "login_count",         default: 0, null: false
    t.integer  "failed_login_count",  default: 0, null: false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_account_id"
    t.string   "full_name"
    t.string   "role"
  end

end
