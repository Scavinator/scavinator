class Team::UsersController < Team::BaseController
  before_action :require_captain, except: :index

  def index
    @members = @team.team_users.where(approved: true)
  end

  def index_pending
    @members = @team.team_users.where(approved: nil)
  end

  def index_banned
    @members = @team.team_users.where(approved: false)
  end

  def update
    @team.team_users.find(params[:id]).update(approved: param_bool([:team_user][:approved]))
    redirect_back fallback_location: :index
  end
end
