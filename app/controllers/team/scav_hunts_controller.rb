class Team::ScavHuntsController < Team::BaseController
  include Discord

  before_action :set_team_scav_hunt, only: [:edit, :update]

  def index
    @scav_hunts = @team.team_scav_hunts
  end

  def edit
    if !@user.discord_id.nil?
      flash[:last_team_prefix] = @team.prefix
      flash[:last_team_path] = edit_team_scav_hunt_path(@team_scav_hunt)
    end
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

  def show
    @team_scav_hunt = @team.team_scav_hunts.find_by(slug: params[:slug])
    item_page_numbers = @team_scav_hunt.items.group(:page_number).select(:page_number).where.not(page_number: nil).map(&:page_number)
    page_captain_page_numbers = @team_scav_hunt.page_captains.group(:page_number).select(:page_number).map(&:page_number)
    @page_numbers = [item_page_numbers, page_captain_page_numbers].flatten.uniq.sort
    @my_items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id})
    @my_roles = @team_scav_hunt.team_role_members.where(user_id: @user.id).map(&:team_role)
  end

  def new
    @eligable_scav_hunts = ScavHunt.left_joins(:team_scav_hunts).where.not(team_scav_hunts: {team_id: @team.id}).or(TeamScavHunt.where(team_id: nil))
  end

  def create
    hunt = @team.team_scav_hunts.create(params[:team_scav_hunt].permit(:slug, :name, :scav_hunt_id))
    redirect_to team_scav_hunt_path(hunt)
  end

  private
    def update_team
      @team_scav_hunt.update(discord_params)
      redirect_to action: :show
    end

    def set_team_scav_hunt
      @team_scav_hunt = @team.team_scav_hunts.find_by!(slug: params[:slug])
    end

    def discord_params
      params.require(:team_scav_hunt).permit(
        :discord_items_channel_id,
        :discord_pages_channel_id,
        :discord_guild_id
      )
    end
end
