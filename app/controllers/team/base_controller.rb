class Team::BaseController < ApplicationController
  before_action :set_team_by_prefix, :set_user_by_cookie, :set_team_user

  private
    def set_team_by_prefix
      @team = Team.find_by!(prefix: params.expect(:team_prefix))
    end

    def set_user_by_cookie
      @user = find_session_by_cookie.user
    end

    def set_team_user
      @team_user = TeamUser.find_by!(team_id: @team.id, user_id: @user.id, approved: true)
    end

    def require_captain
      # Seems to be the best way to get a 404 :/
      raise ActiveRecord::RecordNotFound, "Not a captain" unless @team_user.captain
    end
end
