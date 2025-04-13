module Discord
  class DiscordClient
    include HTTParty

    base_uri "https://discord.com/api/v10"
  end

  class DiscordBotClient < DiscordClient
    headers "Authorization" => "Bot #{Rails.application.credentials.discord_token!}"
  end
end
