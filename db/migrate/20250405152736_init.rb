class Init < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.text :name, null: false
      t.text :email_address, null: false, index: {unique: true}
      t.string :password_digest, null: false
      t.boolean :admin, default: false, null: false

      t.timestamps
    end

    create_table :teams do |t|
      t.text :affiliation, null: false
      t.text :prefix, null: false, index: {unique: true}
      t.boolean :virtual, null: false
      t.boolean :uchicago, null: false

      t.timestamps
    end

    create_table :team_users do |t|
      t.boolean :captain, null: false, default: false
      t.boolean :approved, null: false
      t.boolean :invited, null: false
      t.references :team, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.index [:team_id, :user_id], unique: true

      t.timestamps
    end

    create_table :scav_hunts do |t|
      t.datetime :start
      t.datetime :end
      t.text :name, null: false

      t.timestamps
    end

    create_table :team_scav_hunts do |t|
      t.text :name, null: false
      t.text :slug, null: false
      t.references :scav_hunt, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.index [:team_id, :scav_hunt_id], unique: true
      t.index [:team_id, :slug], unique: true
      t.text :discord_guild_id
      t.text :discord_items_channel_id, index: {unique: true}
      t.text :discord_pages_channel_id, index: {unique: true}
      t.text :discord_items_message_id, index: {unique: true}
      t.text :discord_pages_message_id, index: {unique: true}

      t.timestamps
    end

    create_table :team_roles do |t|
      t.references :team, null: false, foreign_key: true
      t.text :name, null: false
      t.boolean :enabled, null: false, default: true

      t.timestamps
    end

    create_table :team_tags do |t|
      t.text :name, null: false
      t.boolean :enabled, null: false, default: true
      t.text :color
      t.references :team, null: false, foreign_key: true
      t.references :team_role, foreign_key: true

      t.timestamps
    end

    create_table :team_role_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team_scav_hunt, null: false, foreign_key: true
      t.references :team_role, null: false, foreign_key: true
      t.index [:user_id, :team_scav_hunt_id, :team_role_id], unique: true

      t.timestamps
    end

    create_table :items do |t|
      t.references :team_scav_hunt, null: false, foreign_key: true
      t.integer :number
      t.integer :page_number
      t.text :content
      t.text :discord_thread_id, index: {unique: true}
      t.index [:team_scav_hunt_id, :number], unique: true

      t.timestamps
    end

    create_table :pages do |t|
      t.references :team_scav_hunt, null: false, foreign_key: true
      t.integer :page_number, null: false
      t.text :discord_thread_id, index: {unique: true}
      t.text :discord_message_id, index: {unique: true}
      t.index [:team_scav_hunt_id, :page_number], unique: true

      t.timestamps
    end

    create_table :item_tags do |t|
      t.references :item, null: false, foreign_key: true
      t.references :team_tag, null: false, foreign_key: true
      t.index [:item_id, :team_tag_id], unique: true
      t.boolean :accepted

      t.timestamps
    end

    create_table :page_captains do |t|
      t.references :team_scav_hunt, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.index [:user_id, :team_scav_hunt_id], unique: true
      t.integer :page_number, null: false

      t.timestamps
    end

    create_table :item_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.index [:user_id, :item_id], unique: true

      t.timestamps
    end
  end
end
