module ApplicationHelper
  def discord_connect_account_uri(team: nil, user:, path: nil)
    state = {user_id: user.id}
    state[:path] = path if path
    state[:prefix] = team.prefix if team
    discord_oauth_uri(link_discord_url(domain: Rails.configuration.scavinator_domain), qs: {state: Rails.application.message_verifier(:discord_state).generate(state)}).to_s
  end

  def discord_oauth_uri(redirect_uri, qs: {})
    base = URI("https://discord.com/oauth2/authorize")
    base.query = URI.encode_www_form(
      response_type: 'code',
      client_id: Rails.application.credentials.discord_client_id!,
      scope: 'identify',
      redirect_uri: redirect_uri,
      **qs
    )
    return base
  end

  def current_authcode
    @team.team_auths.find_by(key: cookies.signed[:scavinator_authcode])
  end

  def item_type_icons(item)
    icons = []
    icons.push("💾") if item.digital_submission
    icons.push("⌚") if item.timed
    return icons.join('')
  end

  def item_status_icons(item)
    if item.submitted
      "✅ "
    elsif item.assigned
      "👷"
    end
  end
end
