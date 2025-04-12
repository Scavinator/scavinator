class TeamController < ApplicationController
  before_action :set_team_by_prefix
  before_action :set_user_by_cookie, :set_team_user, except: [:new_session, :create_session]
  skip_before_action :require_authentication, only: [:new_session, :create_session]

  def show
    @scav_hunt = @team.team_scav_hunts.first
    redirect_to team_scav_hunt_path(@team, @scav_hunt) unless @scav_hunt.nil? || @team_user.captain
  end

  def new_session
    render 'login'
  end

  def create_session
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to team_path(@team)
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
