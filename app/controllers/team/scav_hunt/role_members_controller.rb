class Team::ScavHunt::RoleMembersController < Team::ScavHunt::BaseController
  def index
    @captains = @team.team_users.where(captain: true)
    @team_users = @team.team_users.where(approved: true)
    @page_captains = @team_scav_hunt.page_captains.all
    if @team_user.captain
      @leadership = @team.team_roles.left_joins(:team_role_members).where(enabled: true, team_id: @team.id)
    else
      @leadership = TeamRole.joins(:team_role_members).where(team_role_members: {team_scav_hunt_id: @team_scav_hunt.id}, team_id: @team.id, enabled: true)
    end
  end

  def create
    TeamRoleMember
      .joins(:team_role)
      .where(team_role: {enabled: true, team_id: @team.id})
      .create(
        team_scav_hunt_id: @team_scav_hunt.id,
        team_role_id: params[:team_role_member][:team_role_id],
        user_id: params[:team_role_member][:user_id])
    redirect_to action: :index
  end

  def destroy
    TeamRoleMember
      .joins(:team_role)
      .where(team_role: {enabled: true, team_id: @team.id})
      .find_by!(team_scav_hunt_id: @team_scav_hunt.id, id: params[:id]).delete
    redirect_to action: :index
  end
end
