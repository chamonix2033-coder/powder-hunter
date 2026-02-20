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

ActiveRecord::Schema[8.1].define(version: 2026_02_20_082913) do
  create_table "selections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "ski_resort_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["ski_resort_id"], name: "index_selections_on_ski_resort_id"
    t.index ["user_id"], name: "index_selections_on_user_id"
  end

  create_table "ski_resorts", force: :cascade do |t|
    t.integer "cached_powder_index"
    t.datetime "created_at", null: false
    t.float "elevation_base"
    t.float "elevation_top"
    t.integer "last_powder_index"
    t.float "latitude"
    t.float "longitude"
    t.string "name_en"
    t.string "name_ja"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "selections", "ski_resorts"
  add_foreign_key "selections", "users"
end
