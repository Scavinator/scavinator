class ItemsAddDiscordMessageId < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :discord_message_id, :text
  end
end
