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

ActiveRecord::Schema.define(version: 20170507100013) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "menu_groups", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["user_id"], name: "index_menu_groups_on_user_id", using: :btree
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer  "menu_group_id"
    t.float    "price"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "image"
    t.index ["menu_group_id"], name: "index_menu_items_on_menu_group_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.json     "order_list",    default: []
    t.integer  "user_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "paid",          default: false
    t.integer  "table_number"
    t.integer  "fb_id"
    t.string   "business_name"
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.text     "description"
    t.string   "category"
    t.string   "location"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "menu_groups", "users"
  add_foreign_key "menu_items", "menu_groups"
  add_foreign_key "orders", "users"
end
