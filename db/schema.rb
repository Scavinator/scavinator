# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "integration_type", ["discord"]
  create_enum "item_status", ["box"]

  create_table "item_integrations", primary_key: ["type", "item_id"], force: :cascade do |t|
    t.bigint "item_id", null: false
    t.jsonb "integration_data"
    t.enum "type", null: false, enum_type: "integration_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "((integration_data ->> 'message_id'::text))", name: "item_integrations_discord_message_id_unique", unique: true, where: "(type = 'discord'::integration_type)"
    t.index "((integration_data ->> 'thread_id'::text))", name: "item_integrations_discord_thread_id_unique", unique: true, where: "(type = 'discord'::integration_type)"
  end

  create_table "item_tags", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "team_tag_id", null: false
    t.boolean "accepted"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["item_id", "team_tag_id"], name: "item_tags_unique"
  end

  create_table "item_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["user_id", "item_id"], name: "item_users_unique"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "team_scav_hunt_id", null: false
    t.integer "number"
    t.integer "page_number"
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "list_category_id"
    t.enum "status", enum_type: "item_status"
    t.text "submission_summary"
    t.index "team_scav_hunt_id, COALESCE(list_category_id, ('-1'::integer)::bigint), number", name: "team_scav_hunt_list_category_item_number_unique", unique: true
    t.check_constraint "NOT (page_number IS NULL AND list_category_id IS NULL)", name: "list_category_or_page_number"
  end

  create_table "list_categories", force: :cascade do |t|
    t.text "name", null: false
    t.bigint "team_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "slug", null: false

    t.unique_constraint ["slug"], name: "list_categories_slug_key"
  end

  create_table "page_captains", force: :cascade do |t|
    t.bigint "team_scav_hunt_id", null: false
    t.bigint "user_id", null: false
    t.integer "page_number", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["page_number", "user_id", "team_scav_hunt_id"], name: "team_scav_hunt_pages_page_captains_unique"
  end

  create_table "page_integrations", primary_key: ["type", "page_id"], force: :cascade do |t|
    t.bigint "page_id", null: false
    t.jsonb "integration_data"
    t.enum "type", null: false, enum_type: "integration_type"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index "((integration_data ->> 'message_id'::text))", name: "page_integrations_discord_message_id_unique", unique: true, where: "(type = 'discord'::integration_type)"
    t.index "((integration_data ->> 'thread_id'::text))", name: "page_integrations_discord_thread_id_unique", unique: true, where: "(type = 'discord'::integration_type)"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "team_scav_hunt_id", null: false
    t.integer "page_number"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["team_scav_hunt_id", "page_number"], name: "team_scav_hunt_pages_unique"
  end

  create_table "scav_hunts", force: :cascade do |t|
    t.datetime "start", precision: nil
    t.datetime "end", precision: nil
    t.text "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "slug", null: false

    t.unique_constraint ["slug"], name: "scav_hunts_slug_key"
  end

  create_table "schema_version", id: false, force: :cascade do |t|
    t.integer "version", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "ip_address"
    t.text "user_agent"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "team_integrations", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.jsonb "integration_data"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["integration_data"], name: "team_integrations_integration_data_key"
  end

  create_table "team_role_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_scav_hunt_id", null: false
    t.bigint "team_role_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["user_id", "team_scav_hunt_id", "team_role_id"], name: "team_role_members_unique"
  end

  create_table "team_roles", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.text "name", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "team_scav_hunts", force: :cascade do |t|
    t.text "name", null: false
    t.bigint "scav_hunt_id"
    t.bigint "team_id", null: false
    t.text "discord_guild_id"
    t.text "discord_items_channel_id"
    t.text "discord_pages_channel_id"
    t.text "discord_items_message_id"
    t.text "discord_pages_message_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["discord_items_channel_id"], name: "team_scav_hunts_discord_items_channel_id_key"
    t.unique_constraint ["discord_items_message_id"], name: "team_scav_hunts_discord_items_message_id_key"
    t.unique_constraint ["discord_pages_channel_id"], name: "team_scav_hunts_discord_pages_channel_id_key"
    t.unique_constraint ["discord_pages_message_id"], name: "team_scav_hunts_discord_pages_message_id_key"
    t.unique_constraint ["scav_hunt_id", "team_id"], name: "team_scav_hunt_unique_per_scav_per_team"
  end

  create_table "team_tags", force: :cascade do |t|
    t.text "name", null: false
    t.boolean "enabled", default: false, null: false
    t.text "color"
    t.bigint "team_id", null: false
    t.bigint "team_role_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "team_users", force: :cascade do |t|
    t.boolean "captain", default: false, null: false
    t.boolean "approved", null: false
    t.boolean "invited", null: false
    t.bigint "team_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["team_id", "user_id"], name: "team_users_unique"
  end

  create_table "teams", force: :cascade do |t|
    t.text "affiliation", null: false
    t.text "prefix"
    t.boolean "virtual", null: false
    t.boolean "uchicago", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["prefix"], name: "teams_prefix_key"
  end

  create_table "users", force: :cascade do |t|
    t.text "name", null: false
    t.text "email_address", null: false
    t.text "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "discord_id"

    t.unique_constraint ["email_address"], name: "users_email_address_key"
  end

  add_foreign_key "item_integrations", "items", name: "item_integrations_item_id_fkey"
  add_foreign_key "item_tags", "items", name: "item_tags_item_id_fkey"
  add_foreign_key "item_tags", "team_tags", name: "item_tags_team_tag_id_fkey"
  add_foreign_key "item_users", "items", name: "item_users_item_id_fkey"
  add_foreign_key "item_users", "users", name: "item_users_user_id_fkey"
  add_foreign_key "items", "list_categories", name: "items_list_category_id_fkey"
  add_foreign_key "items", "team_scav_hunts", name: "items_team_scav_hunt_id_fkey"
  add_foreign_key "list_categories", "teams", name: "list_categories_team_id_fkey"
  add_foreign_key "page_captains", "team_scav_hunts", name: "page_captains_team_scav_hunt_id_fkey"
  add_foreign_key "page_captains", "users", name: "page_captains_user_id_fkey"
  add_foreign_key "page_integrations", "pages", name: "page_integrations_page_id_fkey"
  add_foreign_key "pages", "team_scav_hunts", name: "pages_team_scav_hunt_id_fkey"
  add_foreign_key "sessions", "users", name: "sessions_user_id_fkey"
  add_foreign_key "team_integrations", "teams", name: "team_integrations_team_id_fkey"
  add_foreign_key "team_role_members", "team_roles", name: "team_role_members_team_role_id_fkey"
  add_foreign_key "team_role_members", "team_scav_hunts", name: "team_role_members_team_scav_hunt_id_fkey"
  add_foreign_key "team_role_members", "users", name: "team_role_members_user_id_fkey"
  add_foreign_key "team_roles", "teams", name: "team_roles_team_id_fkey"
  add_foreign_key "team_scav_hunts", "scav_hunts", name: "team_scav_hunts_scav_hunt_id_fkey"
  add_foreign_key "team_scav_hunts", "teams", name: "team_scav_hunts_team_id_fkey"
  add_foreign_key "team_tags", "team_roles", name: "team_tags_team_role_id_fkey"
  add_foreign_key "team_tags", "teams", name: "team_tags_team_id_fkey"
  add_foreign_key "team_users", "teams", name: "team_users_team_id_fkey"
  add_foreign_key "team_users", "users", name: "team_users_user_id_fkey"
end
