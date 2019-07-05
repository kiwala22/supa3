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

ActiveRecord::Schema.define(version: 2019_07_05_132010) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "broadcasts", force: :cascade do |t|
    t.string "status"
    t.string "message"
    t.integer "contacts"
    t.bigint "user_id"
    t.string "segment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "execution_time"
    t.index ["user_id"], name: "index_broadcasts_on_user_id"
  end

  create_table "draws", force: :cascade do |t|
    t.datetime "draw_time"
    t.decimal "revenue", precision: 12, scale: 2
    t.decimal "payout", precision: 12, scale: 2
    t.integer "two_match"
    t.string "three_match"
    t.integer "one_match"
    t.integer "no_match"
    t.integer "ticket_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gamers", force: :cascade do |t|
    t.string "phone_number"
    t.decimal "probability_to_play", precision: 5, scale: 2
    t.decimal "predicted_revenue", precision: 8, scale: 2
    t.string "segment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number"], name: "index_gamers_on_phone_number", unique: true
  end

  create_table "segments", force: :cascade do |t|
    t.integer "a"
    t.integer "b"
    t.integer "c"
    t.integer "d"
    t.integer "e"
    t.integer "f"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", force: :cascade do |t|
    t.string "phone_number"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "time"
    t.integer "number_matches"
    t.string "reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "gamer_id"
    t.string "data"
    t.bigint "draw_id"
    t.decimal "win_amount", precision: 10, scale: 2
    t.boolean "paid", default: false
    t.index ["draw_id"], name: "index_tickets_on_draw_id"
    t.index ["gamer_id"], name: "index_tickets_on_gamer_id"
    t.index ["reference"], name: "index_tickets_on_reference"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "broadcasts", "users"
  add_foreign_key "tickets", "draws"
  add_foreign_key "tickets", "gamers"
end
