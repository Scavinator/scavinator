class TeamController < Team::BaseController
  skip_before_action :require_authentication, :set_user_by_cookie, :set_team_user, only: [:new_session, :create_session]
  before_action :require_captain, only: [:settings]

  def show
    @scav_hunts = @team.team_scav_hunts
    redirect_to team_scav_hunt_path(@scav_hunts.first) unless @scav_hunts.empty? || @team_user.captain
  end

  def settings
  end

  def new_session
    render 'login'
  end

  def create_session
    user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
    if user
      start_new_session_for user
      redirect_to team_path
    else
      redirect_to team_new_session_path, alert: "Try another email address or password."
    end
  end

  private
    def set_team_by_prefix
      @team = Team.find_by!(prefix: request.path_parameters[:prefix] || request.path_parameters[:team_prefix])
    end

    def set_user_by_cookie
      @user = find_session_by_cookie.user
    end

    def set_team_user
      @team_user = TeamUser.find_by!(team_id: @team.id, user_id: @user.id, approved: true)
    end
end
