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

ActiveRecord::Schema.define(version: 20180322204008) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "title"
    t.date     "day"
    t.time     "time"
    t.text     "description"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "publish",     default: false
    t.time     "end_time"
  end

  add_index "activities", ["event_id"], name: "index_activities_on_event_id", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "early_arrivals", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date     "ea_date"
  end

  add_index "early_arrivals", ["event_id"], name: "index_early_arrivals_on_event_id", using: :btree
  add_index "early_arrivals", ["user_id"], name: "index_early_arrivals_on_user_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "year"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "theme"
    t.string   "camp_address"
    t.date     "early_arrival_date"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "camp_org"
    t.decimal  "camp_dues",          default: 0.0
    t.decimal  "camp_dues_food",     default: 0.0
    t.integer  "organizer_id"
    t.boolean  "accepting_apps"
    t.string   "camp_dues_mail"
    t.string   "camp_dues_paypal"
    t.boolean  "archive",            default: false
    t.boolean  "camp_closed",        default: false
  end

  create_table "intentions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "status"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.date     "arrival_date"
    t.date     "departure_date"
    t.integer  "transportation"
    t.integer  "seats_available"
    t.integer  "lodging"
    t.boolean  "yurt_owner",               default: false
    t.boolean  "yurt_storage",             default: false
    t.string   "yurt_panel_size"
    t.string   "yurt_user"
    t.boolean  "opt_in_meals"
    t.text     "food_restrictions"
    t.text     "logistics"
    t.integer  "event_id"
    t.integer  "tickets_for_sale"
    t.integer  "storage_bikes"
    t.integer  "logistics_bike"
    t.integer  "logistics_bins"
    t.integer  "lodging_num_occupants"
    t.boolean  "shipping_yurt"
    t.decimal  "camp_due_storage",         default: 0.0
    t.boolean  "storage_tenent",           default: false
    t.datetime "dues_last_sent"
    t.string   "lodging_footprint"
    t.string   "vehicle_type"
    t.boolean  "interested_in_rental_van"
    t.boolean  "stryke_confirmation"
  end

  add_index "intentions", ["user_id", "event_id"], name: "index_intentions_on_user_id_and_event_id", using: :btree
  add_index "intentions", ["user_id"], name: "index_intentions_on_user_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "invite_digest"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "last_sent_at"
    t.integer  "membership_application_id"
  end

  add_index "invitations", ["email"], name: "index_invitations_on_email", unique: true, using: :btree
  add_index "invitations", ["membership_application_id"], name: "index_invitations_on_membership_application_id", using: :btree

  create_table "membership_applications", force: :cascade do |t|
    t.string   "name"
    t.string   "playa_name"
    t.string   "email"
    t.string   "phone"
    t.string   "home_town"
    t.text     "possibility"
    t.text     "contribution"
    t.text     "passions"
    t.integer  "years_at_bm"
    t.boolean  "approved"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.text     "member_acquaintance"
    t.boolean  "archived",            default: false
  end

  create_table "payments", force: :cascade do |t|
    t.date     "payment_date"
    t.decimal  "amount",       default: 0.0
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "user_id"
    t.integer  "event_id"
    t.text     "description"
  end

  add_index "payments", ["event_id"], name: "index_payments_on_event_id", using: :btree
  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "tickets", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "admission_qty"
    t.integer  "parking_qty"
    t.string   "confirmation_number"
    t.integer  "event_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "status",              default: 1
    t.string   "verification_digest"
    t.datetime "verified_at"
    t.boolean  "verified",            default: false
  end

  add_index "tickets", ["event_id"], name: "index_tickets_on_event_id", using: :btree

  create_table "user_notes", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_notes", ["user_id"], name: "index_user_notes_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",                     default: false
    t.string   "activation_digest"
    t.boolean  "activated",                 default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "phone"
    t.string   "playa_name"
    t.string   "hometown"
    t.boolean  "added_to_google_group",     default: false
    t.integer  "membership_application_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["membership_application_id"], name: "index_users_on_membership_application_id", using: :btree

  add_foreign_key "activities", "events"
  add_foreign_key "activities", "users"
  add_foreign_key "early_arrivals", "events"
  add_foreign_key "early_arrivals", "users"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "intentions", "users"
  add_foreign_key "invitations", "membership_applications"
  add_foreign_key "payments", "events"
  add_foreign_key "payments", "users"
  add_foreign_key "tickets", "events"
  add_foreign_key "user_notes", "users"
  add_foreign_key "users", "membership_applications"
end
