class TeamController < Team::BaseController
  allow_public_access only: [:new_session, :create_session]
  allow_authcode_access only: [:show]
  require_captain only: [:settings]

  def show
    @scav_hunts = @team.team_scav_hunts
    redirect_to team_scav_hunt_path(@scav_hunts.first) unless @scav_hunts.empty? || @team_user&.captain
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
      redirect_to after_authentication_url || team_path
    else
      redirect_to team_new_session_path, alert: "Try another email address or password."
    end
  end
end
