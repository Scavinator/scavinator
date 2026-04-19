class Team::Users::CaptainsController < Team::BaseController
  require_captain

  def index
    @captains = @team.team_users.where(captain: true)
    @team_users = @team.team_users.where(captain: false, approved: true)
  end

  def create
    @team.team_users.find(params.require(:team_user).require(:id)).update(captain: true)
    redirect_to team_users_captains_url(@team)
  end

  def destroy
    team_user = @team.team_users.find(params.require(:id))
    if @user.id == team_user.user.id
      team_user.update(captain: false)
    end
    redirect_to team_users_captains_url(@team)
  end
end
