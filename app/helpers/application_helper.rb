module ApplicationHelper
  def discord_oauth_uri
    "https://discord.com/oauth2/authorize?response_type=code&client_id=#{Rails.application.credentials.discord_client_id!}&scope=identify&redirect_uri=#{discord_redirect_uri}"
  end

  def discord_redirect_uri
    "#{Rails.configuration.scavinator_uri}/users/me/discord"
  end
end
