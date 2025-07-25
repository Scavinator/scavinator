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

ActiveRecord::Schema[8.0].define(version: 2025_05_31_003154) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "item_status", ["claimed", "help", "box"]

  create_table "item_tags", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "team_tag_id", null: false
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "team_tag_id"], name: "index_item_tags_on_item_id_and_team_tag_id", unique: true
    t.index ["item_id"], name: "index_item_tags_on_item_id"
    t.index ["team_tag_id"], name: "index_item_tags_on_team_tag_id"
  end

  create_table "item_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_users_on_item_id"
    t.index ["user_id", "item_id"], name: "index_item_users_on_user_id_and_item_id", unique: true
    t.index ["user_id"], name: "index_item_users_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "team_scav_hunt_id", null: false
    t.integer "number"
    t.integer "page_number"
    t.text "content"
    t.text "discord_thread_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "list_category_id"
    t.enum "status", enum_type: "item_status"
    t.text "discord_message_id"
    t.index ["discord_thread_id"], name: "index_items_on_discord_thread_id", unique: true
    t.index ["list_category_id"], name: "index_items_on_list_category_id"
    t.index ["team_scav_hunt_id", "list_category_id", "number"], name: "idx_on_team_scav_hunt_id_list_category_id_number_65820b60c9", unique: true, nulls_not_distinct: true
    t.index ["team_scav_hunt_id"], name: "index_items_on_team_scav_hunt_id"
    t.check_constraint "NOT (page_number IS NULL AND list_category_id IS NULL)", name: "list_category_or_page_number"
  end

  create_table "list_categories", force: :cascade do |t|
    t.text "name", null: false
    t.bigint "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slug", null: false
    t.index ["slug"], name: "index_list_categories_on_slug", unique: true
    t.index ["team_id"], name: "index_list_categories_on_team_id"
  end

  create_table "page_captains", force: :cascade do |t|
    t.bigint "team_scav_hunt_id", null: false
    t.bigint "user_id", null: false
    t.integer "page_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_scav_hunt_id"], name: "index_page_captains_on_team_scav_hunt_id"
    t.index ["user_id", "team_scav_hunt_id"], name: "index_page_captains_on_user_id_and_team_scav_hunt_id", unique: true
    t.index ["user_id"], name: "index_page_captains_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "team_scav_hunt_id", null: false
    t.integer "page_number", null: false
    t.text "discord_thread_id"
    t.text "discord_message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_message_id"], name: "index_pages_on_discord_message_id", unique: true
    t.index ["discord_thread_id"], name: "index_pages_on_discord_thread_id", unique: true
    t.index ["team_scav_hunt_id", "page_number"], name: "index_pages_on_team_scav_hunt_id_and_page_number", unique: true
    t.index ["team_scav_hunt_id"], name: "index_pages_on_team_scav_hunt_id"
  end

  create_table "scav_hunts", force: :cascade do |t|
    t.datetime "start"
    t.datetime "end"
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "slug", null: false
    t.index ["slug"], name: "index_scav_hunts_on_slug", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "team_integrations", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.jsonb "integration_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["integration_data"], name: "index_team_integrations_on_integration_data", unique: true
    t.index ["team_id"], name: "index_team_integrations_on_team_id"
  end

  create_table "team_role_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_scav_hunt_id", null: false
    t.bigint "team_role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_role_id"], name: "index_team_role_members_on_team_role_id"
    t.index ["team_scav_hunt_id"], name: "index_team_role_members_on_team_scav_hunt_id"
    t.index ["user_id", "team_scav_hunt_id", "team_role_id"], name: "idx_on_user_id_team_scav_hunt_id_team_role_id_daf64ece48", unique: true
    t.index ["user_id"], name: "index_team_role_members_on_user_id"
  end

  create_table "team_roles", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.text "name", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_roles_on_team_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_items_channel_id"], name: "index_team_scav_hunts_on_discord_items_channel_id", unique: true
    t.index ["discord_items_message_id"], name: "index_team_scav_hunts_on_discord_items_message_id", unique: true
    t.index ["discord_pages_channel_id"], name: "index_team_scav_hunts_on_discord_pages_channel_id", unique: true
    t.index ["discord_pages_message_id"], name: "index_team_scav_hunts_on_discord_pages_message_id", unique: true
    t.index ["scav_hunt_id"], name: "index_team_scav_hunts_on_scav_hunt_id"
    t.index ["team_id", "scav_hunt_id"], name: "index_team_scav_hunts_on_team_id_and_scav_hunt_id", unique: true
    t.index ["team_id"], name: "index_team_scav_hunts_on_team_id"
  end

  create_table "team_tags", force: :cascade do |t|
    t.text "name", null: false
    t.boolean "enabled", default: true, null: false
    t.text "color"
    t.bigint "team_id", null: false
    t.bigint "team_role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_tags_on_team_id"
    t.index ["team_role_id"], name: "index_team_tags_on_team_role_id"
  end

  create_table "team_users", force: :cascade do |t|
    t.boolean "captain", default: false, null: false
    t.boolean "approved", null: false
    t.boolean "invited", null: false
    t.bigint "team_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "user_id"], name: "index_team_users_on_team_id_and_user_id", unique: true
    t.index ["team_id"], name: "index_team_users_on_team_id"
    t.index ["user_id"], name: "index_team_users_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.text "affiliation", null: false
    t.text "prefix"
    t.boolean "virtual", null: false
    t.boolean "uchicago", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["prefix"], name: "index_teams_on_prefix", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "name", null: false
    t.text "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "discord_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "item_tags", "items"
  add_foreign_key "item_tags", "team_tags"
  add_foreign_key "item_users", "items"
  add_foreign_key "item_users", "users"
  add_foreign_key "items", "list_categories"
  add_foreign_key "items", "team_scav_hunts"
  add_foreign_key "list_categories", "teams"
  add_foreign_key "page_captains", "team_scav_hunts"
  add_foreign_key "page_captains", "users"
  add_foreign_key "pages", "team_scav_hunts"
  add_foreign_key "sessions", "users"
  add_foreign_key "team_integrations", "teams"
  add_foreign_key "team_role_members", "team_roles"
  add_foreign_key "team_role_members", "team_scav_hunts"
  add_foreign_key "team_role_members", "users"
  add_foreign_key "team_roles", "teams"
  add_foreign_key "team_scav_hunts", "scav_hunts"
  add_foreign_key "team_scav_hunts", "teams"
  add_foreign_key "team_tags", "team_roles"
  add_foreign_key "team_tags", "teams"
  add_foreign_key "team_users", "teams"
  add_foreign_key "team_users", "users"
end
