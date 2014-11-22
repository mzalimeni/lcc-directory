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

ActiveRecord::Schema.define(version: 20141122185655) do

  create_table "families", force: true do |t|
    t.integer  "head_id"
    t.date     "anniversary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",            default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "preferred_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.integer  "postal_code"
    t.string   "mobile_phone"
    t.string   "home_phone"
    t.string   "work_phone"
    t.date     "birthday"
    t.integer  "family_id"
    t.integer  "spouse_id"
    t.boolean  "directory_public", default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["family_id"], name: "index_users_on_family_id"
  add_index "users", ["first_name"], name: "index_users_on_first_name"
  add_index "users", ["last_name"], name: "index_users_on_last_name"
  add_index "users", ["preferred_name"], name: "index_users_on_preferred_name"
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"
  add_index "users", ["spouse_id"], name: "index_users_on_spouse_id"

end
