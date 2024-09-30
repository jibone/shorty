# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_09_30_085123) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "link_clicks", force: :cascade do |t|
    t.bigint "link_id", null: false
    t.string "ip_address"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "device_type"
    t.string "browser_name"
    t.string "browser_version"
    t.string "os_name"
    t.string "os_version"
    t.string "referer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_id"], name: "index_link_clicks_on_link_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "label"
    t.string "target_url"
    t.string "short_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "title"
    t.index ["short_code"], name: "index_links_on_short_code", unique: true
    t.index ["short_code"], name: "index_unique_on_short_sode", unique: true
    t.index ["user_id"], name: "index_links_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_token"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "link_clicks", "links"
  add_foreign_key "links", "users"
end
