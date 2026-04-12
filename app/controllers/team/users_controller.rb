class Team::UsersController < Team::BaseController
  require_captain except: :index

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
    value = params.require(:team_user).require(:approved)
    raise ActionController::BadRequest, "Missing valid team_user.approved value" unless %w[true false].include? value
    @team.team_users.find(request.path_parameters[:id]).update(approved: value == "true")
    redirect_to team_users_path
  end
end
