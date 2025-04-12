class Team::Users::CaptainsController < Team::BaseController
  before_action :require_captain

  def index
    @captains = @team.team_users.where(captain: true)
    @team_users = @team.team_users.where(captain: false, approved: true)
  end

  def create
    if captain?
      @team.team_users.find(params[:team_user][:user_id]).update(captain: true)
    end
    redirect_back fallback_location: :index
  end

  def destroy
    team_user = @team.team_users.find(params[:id])
    if @user.id == team_user.user.id
      team_user.update(captain: false)
    end
    redirect_back fallback_location: :index
  end

  private
    def param_bool(param)
      return param == 'true' ? true : (param == 'false' ? false : nil)
    end

    def captain?
      @team_user.captain
    end
end
