module Discord
  class DiscordClient
    include HTTParty

    base_uri "https://discord.com/api/v10"
  end

  class DiscordBotClient < DiscordClient
    headers "Authorization" => "Bot #{Rails.application.credentials.discord_token!}"
  end

  class DiscordFetchError < StandardError
  end

  def discord_user_info(redirect_uri)
    access_token = HTTParty.post("https://discord.com/api/oauth2/token", body: {
      grant_type: 'authorization_code',
      code: params.require(:code),
      redirect_uri: redirect_uri
    }, basic_auth: {
      username: Rails.application.credentials.discord_client_id!,
      password: Rails.application.credentials.discord_client_secret!
    })
    raise DiscordFetchError, "Error getting token from discord. Try again?" unless !access_token['access_token'].nil?
    user = DiscordClient.get('/users/@me', headers: {'Authorization' => "Bearer #{access_token['access_token']}"})
    raise DiscordFetchError, "Error getting token from discord. Try again?" unless !user['id'].nil? && user.code == 200
    return user
  end

  def discord_parse_state(s)
    Rails.application.message_verifier(:discord_state).verify(s)
  end
end
