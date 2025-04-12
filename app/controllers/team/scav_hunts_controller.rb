class Team::ScavHuntsController < Team::BaseController
  def index
    @scav_hunts = @team.team_scav_hunts
  end

  def edit
    @team_scav_hunt = @team.team_scav_hunts.find_by(slug: params[:slug])
  end

  def update
    @team.team_scav_hunts.find_by(slug: params[:slug]).update(params[:team_scav_hunt].permit(
      :discord_items_channel_id,
      :discord_pages_channel_id,
      :discord_guild_id
    ))
    redirect_to action: :show
  end

  def show
    @team_scav_hunt = @team.team_scav_hunts.find_by(slug: params[:slug])
    item_page_numbers = @team_scav_hunt.items.group(:page_number).select(:page_number).map(&:page_number)
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
    redirect_to team_scav_hunt_path(@team, hunt)
  end
end
