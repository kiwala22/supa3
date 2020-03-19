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

ActiveRecord::Schema.define(version: 2020_03_19_065743) do

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

  create_table "api_users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "api_id"
    t.string "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "registered", default: false
    t.string "user_type"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
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
    t.decimal "predicted_revenue_lower", precision: 8, scale: 2
    t.decimal "predicted_revenue_upper", precision: 8, scale: 2
    t.string "method"
    t.index ["user_id"], name: "index_broadcasts_on_user_id"
  end

  create_table "bulks", force: :cascade do |t|
    t.string "phone_number"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "collections", force: :cascade do |t|
    t.string "ext_transaction_id"
    t.string "transaction_id"
    t.string "resource_id"
    t.string "receiving_fri"
    t.string "currency"
    t.decimal "amount", precision: 10, scale: 2
    t.string "phone_number"
    t.string "status"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "network"
    t.index ["ext_transaction_id"], name: "index_collections_on_ext_transaction_id"
    t.index ["phone_number"], name: "index_collections_on_phone_number"
    t.index ["transaction_id"], name: "index_collections_on_transaction_id"
  end

  create_table "disbursements", force: :cascade do |t|
    t.string "ext_transaction_id"
    t.string "currency", default: "UGX"
    t.string "transaction_id"
    t.decimal "amount", precision: 10, scale: 2
    t.string "phone_number"
    t.string "status"
    t.string "message"
    t.string "network"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ext_transaction_id"], name: "index_disbursements_on_ext_transaction_id"
    t.index ["phone_number"], name: "index_disbursements_on_phone_number"
    t.index ["transaction_id"], name: "index_disbursements_on_transaction_id"
  end

  create_table "draw_offers", force: :cascade do |t|
    t.integer "multiplier_one"
    t.integer "multiplier_two"
    t.integer "multiplier_three"
    t.datetime "expiry_time"
    t.string "segment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "multiplier_four"
    t.integer "multiplier_five"
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
    t.decimal "rtp"
    t.integer "mtn_tickets"
    t.integer "airtel_tickets"
    t.integer "users"
    t.integer "new_users"
    t.integer "undefined_tickets"
    t.string "winning_number"
    t.string "game", default: "Supa3"
    t.integer "four_match"
    t.integer "five_match"
  end

  create_table "gamers", force: :cascade do |t|
    t.string "phone_number"
    t.decimal "probability_to_play", precision: 5, scale: 2
    t.decimal "predicted_revenue", precision: 8, scale: 2
    t.string "segment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["phone_number"], name: "index_gamers_on_phone_number", unique: true
  end

  create_table "jackpots", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "ticket_id"
    t.string "game"
    t.boolean "jackpot", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ticket_reference"
  end

  create_table "messages", force: :cascade do |t|
    t.string "to"
    t.string "from"
    t.text "message"
    t.string "sms_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from"], name: "index_messages_on_from"
    t.index ["message"], name: "index_messages_on_message"
    t.index ["sms_type"], name: "index_messages_on_sms_type"
    t.index ["to"], name: "index_messages_on_to"
  end

  create_table "payments", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approved_by"
    t.integer "initiated_by"
    t.string "status"
  end

  create_table "push_pay_broadcasts", force: :cascade do |t|
    t.string "phone_number"
    t.integer "amount"
    t.string "data"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ext_transaction_id"
    t.string "transaction_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "file_name"
    t.string "file_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", force: :cascade do |t|
    t.string "phone_number"
    t.integer "matches"
    t.datetime "time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matches"], name: "index_results_on_matches"
    t.index ["phone_number"], name: "index_results_on_phone_number"
    t.index ["time"], name: "index_results_on_time"
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
    t.integer "g"
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
    t.decimal "win_amount", precision: 10, scale: 2, default: "0.0"
    t.boolean "paid", default: false
    t.string "network"
    t.boolean "confirmation", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "winning_number"
    t.string "keyword"
    t.string "disbursement_reference"
    t.string "game", default: "Supa3"
    t.string "segment"
    t.index ["amount"], name: "index_tickets_on_amount"
    t.index ["data"], name: "index_tickets_on_data"
    t.index ["draw_id"], name: "index_tickets_on_draw_id"
    t.index ["game"], name: "index_tickets_on_game"
    t.index ["gamer_id"], name: "index_tickets_on_gamer_id"
    t.index ["network"], name: "index_tickets_on_network"
    t.index ["number_matches"], name: "index_tickets_on_number_matches"
    t.index ["paid"], name: "index_tickets_on_paid"
    t.index ["phone_number"], name: "index_tickets_on_phone_number"
    t.index ["reference"], name: "index_tickets_on_reference"
    t.index ["segment"], name: "index_tickets_on_segment"
    t.index ["time"], name: "index_tickets_on_time"
    t.index ["win_amount"], name: "index_tickets_on_win_amount"
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
    t.boolean "admin", default: false
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "broadcasts", "users"
  add_foreign_key "tickets", "draws"
  add_foreign_key "tickets", "gamers"
end
