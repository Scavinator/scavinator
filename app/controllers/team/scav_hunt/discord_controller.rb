class Team::ScavHunt::DiscordController < Team::ScavHunt::BaseController
  include Discord

  require_captain

  def edit
  end

  def update
    if @user.discord_id.nil?
      return redirect_to edit_team_scav_hunt_path(@team_scav_hunt)
    end
    discord_guild_data = DiscordBotClient.get("/guilds/#{discord_params[:discord_guild_id]}")
    return render body: "Scavinator bot could not fetch guild data" if discord_guild_data["owner_id"].nil? || discord_guild_data["roles"].nil?
    return update_team if discord_guild_data["owner_id"] == @user.discord_id
    manage_server_role_ids = discord_guild_data["roles"].filter { |role| (role["permissions"].to_i & (1 << 5)) != 0 }.map { |role| role["id"] }
    discord_guild_member_data = DiscordBotClient.get("/guilds/#{discord_params[:discord_guild_id]}/members/#{@user.discord_id}")
    return update_team if discord_guild_member_data["roles"].any? { |role| manage_server_role_ids.include? role }
    render body: "You don't have enough permissions in that server", status: 403
  end

  private
    def update_team
      @team_scav_hunt.update(discord_params)
      redirect_to action: :show
    end

    def discord_params
      params.require(:team_scav_hunt).permit(
        :discord_items_channel_id,
        :discord_pages_channel_id,
        :discord_guild_id
      )
    end
end
