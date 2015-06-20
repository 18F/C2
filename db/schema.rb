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

ActiveRecord::Schema.define(version: 20150620004844) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: true do |t|
    t.string   "access_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "used_at"
    t.integer  "approval_id"
  end

  create_table "approval_delegates", force: true do |t|
    t.integer  "assigner_id"
    t.integer  "assignee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "approval_groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_id"
    t.string   "flow"
  end

  create_table "approval_groups_users", id: false, force: true do |t|
    t.integer "approval_group_id"
    t.integer "user_id"
  end

  create_table "approvals", force: true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "proposal_id"
  end

  create_table "attachments", force: true do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "external_id"
    t.integer  "proposal_id"
  end

  create_table "comments", force: true do |t|
    t.text     "comment_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "proposal_id"
    t.boolean  "update_comment"
  end

  add_index "comments", ["proposal_id"], name: "index_comments_on_proposal_id", using: :btree

  create_table "gsa18f_procurements", force: true do |t|
    t.string   "office"
    t.text     "justification"
    t.string   "link_to_product"
    t.integer  "quantity"
    t.datetime "date_requested"
    t.string   "additional_info"
    t.decimal  "cost_per_unit"
    t.text     "product_name_and_description"
    t.boolean  "recurring"
    t.string   "recurring_interval"
    t.integer  "recurring_length"
    t.string   "urgency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ncr_work_orders", force: true do |t|
    t.decimal  "amount"
    t.string   "expense_type"
    t.string   "vendor"
    t.boolean  "not_to_exceed"
    t.string   "building_number"
    t.boolean  "emergency"
    t.string   "rwa_number"
    t.string   "org_code"
    t.string   "code"
    t.string   "project_title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "direct_pay"
    t.string   "cl_number"
    t.string   "function_code"
    t.string   "soc_code"
  end

  create_table "observations", force: true do |t|
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", force: true do |t|
    t.text    "property"
    t.text    "value"
    t.integer "hasproperties_id"
    t.string  "hasproperties_type"
  end

  create_table "proposals", force: true do |t|
    t.string   "status"
    t.string   "flow"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_data_id"
    t.string   "client_data_type"
    t.integer  "requester_id"
    t.string   "public_id"
  end

  add_index "proposals", ["client_data_id", "client_data_type"], name: "index_proposals_on_client_data_id_and_client_data_type", using: :btree

  create_table "user_roles", force: true do |t|
    t.integer "approval_group_id"
    t.integer "user_id"
    t.string  "role"
    t.integer "position"
  end

  create_table "users", force: true do |t|
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "client_slug"
  end

end
