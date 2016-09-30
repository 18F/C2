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

ActiveRecord::Schema.define(version: 20160930170849) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "ahoy_events", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visit_id"
    t.integer  "user_id"
    t.string   "name"
    t.json     "properties"
    t.datetime "time"
  end

  add_index "ahoy_events", ["time"], name: "index_ahoy_events_on_time", using: :btree
  add_index "ahoy_events", ["user_id"], name: "index_ahoy_events_on_user_id", using: :btree
  add_index "ahoy_events", ["visit_id"], name: "index_ahoy_events_on_visit_id", using: :btree

  create_table "ahoy_messages", force: :cascade do |t|
    t.string   "token"
    t.text     "to"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "mailer"
    t.text     "subject"
    t.text     "content"
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
  end

  add_index "ahoy_messages", ["token"], name: "index_ahoy_messages_on_token", using: :btree
  add_index "ahoy_messages", ["user_id", "user_type"], name: "index_ahoy_messages_on_user_id_and_user_type", using: :btree

  create_table "api_tokens", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "used_at"
    t.integer  "step_id"
  end

  add_index "api_tokens", ["access_token"], name: "index_api_tokens_on_access_token", unique: true, using: :btree

  create_table "attachments", force: :cascade do |t|
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "proposal_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "query_id"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.integer  "query_id"
    t.string   "state"
    t.text     "emails"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.integer  "dashboard_id"
    t.integer  "query_id"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.integer  "creator_id"
    t.string   "name"
    t.text     "description"
    t.text     "statement"
    t.string   "data_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: :cascade do |t|
    t.text     "comment_text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "proposal_id"
    t.boolean  "update_comment"
    t.uuid     "visit_id"
  end

  add_index "comments", ["proposal_id"], name: "index_comments_on_proposal_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "gsa18f_events", force: :cascade do |t|
    t.string   "duty_station"
    t.integer  "supervisor_id"
    t.string   "title_of_event"
    t.string   "event_provider"
    t.string   "purpose"
    t.string   "justification"
    t.string   "link"
    t.string   "instructions"
    t.decimal  "cost_per_unit"
    t.decimal  "estimated_travel_expenses"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "updated_at"
    t.datetime "created_at"
    t.text     "type_of_event"
    t.boolean  "free_event",                default: false
    t.boolean  "travel_required",           default: false
  end

  create_table "gsa18f_procurements", force: :cascade do |t|
    t.text     "office"
    t.text     "justification",                default: "",      null: false
    t.text     "link_to_product",              default: "",      null: false
    t.integer  "quantity"
    t.datetime "date_requested"
    t.text     "additional_info"
    t.decimal  "cost_per_unit"
    t.text     "product_name_and_description"
    t.boolean  "recurring",                    default: false,   null: false
    t.string   "recurring_interval",           default: "Daily"
    t.integer  "recurring_length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "urgency"
    t.integer  "purchase_type",                                  null: false
    t.boolean  "is_tock_billable"
    t.string   "tock_project"
    t.string   "pegasys_document_number"
    t.boolean  "client_billed"
  end

  create_table "ncr_organizations", force: :cascade do |t|
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "code",                    null: false
    t.string   "name",       default: "", null: false
  end

  create_table "ncr_work_orders", force: :cascade do |t|
    t.decimal  "amount"
    t.string   "expense_type"
    t.string   "vendor"
    t.boolean  "not_to_exceed",         default: false, null: false
    t.string   "building_number"
    t.boolean  "emergency",             default: false, null: false
    t.string   "rwa_number"
    t.string   "work_order_code"
    t.string   "project_title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "direct_pay",            default: false, null: false
    t.string   "cl_number"
    t.string   "function_code"
    t.string   "soc_code"
    t.integer  "ncr_organization_id"
    t.integer  "approving_official_id"
  end

  add_index "ncr_work_orders", ["ncr_organization_id"], name: "index_ncr_work_orders_on_ncr_organization_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type", using: :btree
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "proposal_roles", force: :cascade do |t|
    t.integer "role_id",     null: false
    t.integer "user_id",     null: false
    t.integer "proposal_id", null: false
  end

  add_index "proposal_roles", ["role_id", "user_id", "proposal_id"], name: "index_proposal_roles_on_role_id_and_user_id_and_proposal_id", unique: true, using: :btree

  create_table "proposals", force: :cascade do |t|
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "client_data_id"
    t.string   "client_data_type"
    t.integer  "requester_id"
    t.string   "public_id",        limit: 255
    t.uuid     "visit_id"
  end

  add_index "proposals", ["client_data_type", "client_data_id"], name: "index_proposals_on_client_data_type_and_client_data_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "name",                       null: false
    t.json     "query",                      null: false
    t.boolean  "shared",     default: false
    t.integer  "user_id",                    null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.uuid     "visit_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name"], name: "roles_name_idx", unique: true, using: :btree

  create_table "scheduled_reports", force: :cascade do |t|
    t.string   "name",                   null: false
    t.integer  "frequency",  default: 0, null: false
    t.integer  "user_id",                null: false
    t.integer  "report_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "proposal_id"
    t.datetime "completed_at"
    t.string   "type"
    t.integer  "parent_id"
    t.integer  "min_children_needed"
    t.integer  "completer_id"
  end

  add_index "steps", ["completer_id"], name: "index_steps_on_completer_id", using: :btree
  add_index "steps", ["user_id", "proposal_id"], name: "steps_user_proposal_idx", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "user_delegates", force: :cascade do |t|
    t.integer  "assigner_id"
    t.integer  "assignee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "client_slug"
    t.boolean  "active",                        default: true
    t.string   "timezone",          limit: 255, default: "Eastern Time (US & Canada)"
    t.string   "new_features_date"
    t.text     "list_view_config"
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

  create_table "visits", id: :uuid, default: nil, force: :cascade do |t|
    t.uuid     "visitor_id"
    t.string   "ip"
    t.text     "user_agent"
    t.text     "referrer"
    t.text     "landing_page"
    t.integer  "user_id"
    t.string   "referring_domain"
    t.string   "search_keyword"
    t.string   "browser"
    t.string   "os"
    t.string   "device_type"
    t.integer  "screen_height"
    t.integer  "screen_width"
    t.string   "country"
    t.string   "region"
    t.string   "city"
    t.string   "postal_code"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.string   "utm_source"
    t.string   "utm_medium"
    t.string   "utm_term"
    t.string   "utm_content"
    t.string   "utm_campaign"
    t.datetime "started_at"
  end

  add_index "visits", ["user_id"], name: "index_visits_on_user_id", using: :btree

  add_foreign_key "attachments", "proposals", name: "proposal_id_fkey"
  add_foreign_key "attachments", "users", name: "user_id_fkey"
  add_foreign_key "comments", "proposals", name: "proposal_id_fkey"
  add_foreign_key "comments", "users", name: "user_id_fkey"
  add_foreign_key "comments", "visits"
  add_foreign_key "proposal_roles", "proposals", name: "proposal_id_fkey"
  add_foreign_key "proposal_roles", "roles", name: "role_id_fkey"
  add_foreign_key "proposal_roles", "users", name: "user_id_fkey"
  add_foreign_key "proposals", "users", column: "requester_id", name: "requester_id_fkey"
  add_foreign_key "proposals", "visits"
  add_foreign_key "reports", "visits"
  add_foreign_key "scheduled_reports", "reports"
  add_foreign_key "scheduled_reports", "users"
  add_foreign_key "steps", "proposals", name: "proposal_id_fkey", on_delete: :cascade
  add_foreign_key "steps", "steps", column: "parent_id", name: "parent_id_fkey", on_delete: :cascade
  add_foreign_key "steps", "users", column: "completer_id", name: "completer_id_fkey"
  add_foreign_key "steps", "users", name: "user_id_fkey"
  add_foreign_key "user_delegates", "users", column: "assignee_id", name: "assignee_id_fkey"
  add_foreign_key "user_delegates", "users", column: "assigner_id", name: "assigner_id_fkey"
  add_foreign_key "user_roles", "roles", name: "role_id_fkey"
  add_foreign_key "user_roles", "users", name: "user_id_fkey"
end
