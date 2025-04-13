class UsersAddDiscordId < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :discord_id, :text
  end
end
