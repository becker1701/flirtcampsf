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

ActiveRecord::Schema.define(version: 20150311205028) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string   "year"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "theme"
    t.string   "camp_address"
    t.date     "early_arrival_date"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "invite_digest"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "membership_applications", force: :cascade do |t|
    t.string   "birth_name"
    t.string   "playa_name"
    t.string   "email"
    t.string   "phone"
    t.string   "home_town"
    t.text     "possibility"
    t.text     "contribution"
    t.text     "passions"
    t.integer  "years_at_bm"
    t.boolean  "approved"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "phone"
    t.string   "playa_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
