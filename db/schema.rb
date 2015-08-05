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

ActiveRecord::Schema.define(version: 20150730161938) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string   "access_token", limit: 255
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "used_at"
    t.integer  "approval_id"
  end

  create_table "approval_delegates", force: :cascade do |t|
    t.integer  "assigner_id"
    t.integer  "assignee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_id"
    t.string   "flow",       limit: 255
  end

  create_table "approval_groups_users", id: false, force: :cascade do |t|
    t.integer "approval_group_id"
    t.integer "user_id"
  end

  create_table "approvals", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "status",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "proposal_id"
    t.datetime "approved_at"
    t.string   "type"
    t.integer  "parent_id"
    t.integer  "min_children_needed"
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "external_id"
    t.integer  "proposal_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "comment_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "proposal_id"
    t.boolean  "update_comment"
  end

  add_index "comments", ["proposal_id"], name: "index_comments_on_proposal_id", using: :btree

  create_table "gsa18f_procurements", force: :cascade do |t|
    t.string   "office",                       limit: 255
    t.text     "justification"
    t.string   "link_to_product",              limit: 255
    t.integer  "quantity"
    t.datetime "date_requested"
    t.string   "additional_info",              limit: 255
    t.decimal  "cost_per_unit"
    t.text     "product_name_and_description"
    t.boolean  "recurring"
    t.string   "recurring_interval",           limit: 255
    t.integer  "recurring_length"
    t.string   "urgency",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ncr_work_orders", force: :cascade do |t|
    t.decimal  "amount"
    t.string   "expense_type",    limit: 255
    t.string   "vendor",          limit: 255
    t.boolean  "not_to_exceed"
    t.string   "building_number", limit: 255
    t.boolean  "emergency"
    t.string   "rwa_number",      limit: 255
    t.string   "org_code",        limit: 255
    t.string   "code",            limit: 255
    t.string   "project_title",   limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "direct_pay"
    t.string   "cl_number",       limit: 255
    t.string   "function_code",   limit: 255
    t.string   "soc_code",        limit: 255
  end

  create_table "observations", force: :cascade do |t|
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", force: :cascade do |t|
    t.text    "property"
    t.text    "value"
    t.integer "hasproperties_id"
    t.string  "hasproperties_type", limit: 255
  end

  create_table "proposals", force: :cascade do |t|
    t.string   "status",           limit: 255
    t.string   "flow",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_data_id"
    t.string   "client_data_type", limit: 255
    t.integer  "requester_id"
    t.string   "public_id",        limit: 255
  end

  add_index "proposals", ["client_data_id", "client_data_type"], name: "index_proposals_on_client_data_id_and_client_data_type", using: :btree

  create_table "user_roles", force: :cascade do |t|
    t.integer "approval_group_id"
    t.integer "user_id"
    t.string  "role",              limit: 255
    t.integer "position"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email_address", limit: 255
    t.string   "first_name",    limit: 255
    t.string   "last_name",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "client_slug",   limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
