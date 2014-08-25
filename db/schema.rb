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

ActiveRecord::Schema.define(version: 20140825151228) do

  create_table "api_tokens", force: true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.integer  "cart_id"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "used_at"
  end

  create_table "approval_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_id"
  end

  create_table "approval_groups_users", id: false, force: true do |t|
    t.integer "approval_group_id"
    t.integer "user_id"
  end

  create_table "approvals", force: true do |t|
    t.integer  "cart_id"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  create_table "cart_item_traits", force: true do |t|
    t.text     "name"
    t.text     "value"
    t.integer  "cart_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cart_items", force: true do |t|
    t.string   "vendor"
    t.text     "description"
    t.string   "url"
    t.text     "notes"
    t.integer  "quantity"
    t.text     "details"
    t.string   "part_number"
    t.float    "price"
    t.integer  "cart_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", force: true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "external_id"
  end

  create_table "comments", force: true do |t|
    t.text     "comment_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
  end

  create_table "properties", force: true do |t|
    t.text    "property"
    t.text    "value"
    t.integer "hasproperties_id"
    t.string  "hasproperties_type"
  end

  create_table "user_roles", force: true do |t|
    t.integer "approval_group_id"
    t.integer "user_id"
    t.string  "role"
  end

  create_table "users", force: true do |t|
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
