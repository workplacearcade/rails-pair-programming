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

ActiveRecord::Schema.define(version: 2020_11_02_091827) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entities", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.string "name"
    t.index ["parent_id"], name: "index_entities_on_parent_id"
  end

  create_table "entity_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "entity_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "entity_desc_idx"
  end

  create_table "integration_events", id: :serial, force: :cascade do |t|
    t.string "integration"
    t.string "external_identifier"
    t.string "external_username"
    t.datetime "occured_at"
    t.string "name"
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sale_id"
    t.index ["integration", "external_identifier", "name", "external_username", "occured_at"], name: "integration_idx_uniq", unique: true
    t.index ["sale_id"], name: "index_integration_events_on_sale_id"
  end

  create_table "integration_identifiers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "team_id"
    t.bigint "entity_id"
    t.string "identifier"
    t.string "source"
    t.bigint "kpi_group_id"
    t.index ["entity_id"], name: "index_integration_identifiers_on_entity_id"
    t.index ["kpi_group_id"], name: "index_integration_identifiers_on_kpi_group_id"
    t.index ["team_id"], name: "index_integration_identifiers_on_team_id"
    t.index ["user_id"], name: "index_integration_identifiers_on_user_id"
  end

  create_table "iq_metrix_partners", force: :cascade do |t|
    t.string "company_id"
    t.string "name"
    t.string "business_name"
    t.string "endpoint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "entity_id"
    t.jsonb "integration_settings", default: {}
    t.datetime "cancelled_at"
    t.index ["entity_id"], name: "index_iq_metrix_partners_on_entity_id"
  end

  create_table "iq_metrix_performance_groups", force: :cascade do |t|
    t.string "name"
    t.jsonb "sales_query"
    t.integer "iq_metrix_partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kpi_group_id"
    t.string "quantity_attribute", default: "quantity"
    t.index ["iq_metrix_partner_id"], name: "index_iq_metrix_performance_groups_on_iq_metrix_partner_id"
    t.index ["kpi_group_id"], name: "index_iq_metrix_performance_groups_on_kpi_group_id"
  end

  create_table "kpi_group_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kpi_group_id"
    t.string "type"
    t.jsonb "data"
    t.jsonb "metadata"
    t.index ["kpi_group_id"], name: "index_kpi_group_events_on_kpi_group_id"
  end

  create_table "kpi_groups", id: :serial, force: :cascade do |t|
    t.string "title"
    t.integer "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "kpi_type"
    t.string "verb"
    t.string "unit"
    t.string "source", default: "manual"
    t.string "ranking_direction", default: "DESC"
    t.index ["entity_id"], name: "index_kpi_groups_on_entity_id"
  end

  create_table "kpis", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title"
    t.integer "team_id"
    t.integer "kpi_group_id"
    t.index ["kpi_group_id"], name: "index_kpis_on_kpi_group_id"
    t.index ["team_id"], name: "index_kpis_on_team_id"
  end

  create_table "levels", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "level_number"
    t.integer "level_start"
    t.integer "level_end"
    t.string "title"
  end

  create_table "sale_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sale_id"
    t.string "type"
    t.jsonb "data"
    t.jsonb "metadata"
    t.index ["sale_id"], name: "index_sale_events_on_sale_id"
  end

  create_table "sales", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "quantity"
    t.integer "user_id"
    t.integer "kpi_id"
    t.integer "team_id"
    t.string "description"
    t.boolean "backdate", default: false
    t.integer "integration_event_id"
    t.string "source"
    t.jsonb "raw_data"
    t.bigint "entity_id"
    t.index ["entity_id"], name: "index_sales_on_entity_id"
    t.index ["kpi_id"], name: "index_sales_on_kpi_id"
    t.index ["team_id", "created_at"], name: "index_sales_on_team_id_and_created_at"
    t.index ["user_id", "created_at"], name: "index_sales_on_user_id_and_created_at"
  end

  create_table "team_assignments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "team_id"
    t.string "assignment_type"
    t.index ["team_id"], name: "index_team_assignments_on_team_id"
    t.index ["user_id"], name: "index_team_assignments_on_user_id"
  end

  create_table "teams", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "entity_id"
    t.index ["entity_id"], name: "index_teams_on_entity_id"
  end

  create_table "user_targets", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "kpi_id"
    t.integer "team_id"
    t.index ["kpi_id"], name: "index_user_targets_on_kpi_id"
    t.index ["team_id"], name: "index_user_targets_on_team_id"
    t.index ["user_id"], name: "index_user_targets_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "firstname"
    t.string "lastname"
    t.float "experience", default: 0.0
    t.integer "level_id"
    t.integer "entity_id"
    t.integer "sales_count"
    t.index ["entity_id"], name: "index_users_on_entity_id"
    t.index ["level_id"], name: "index_users_on_level_id"
  end

  add_foreign_key "users", "levels"
end
