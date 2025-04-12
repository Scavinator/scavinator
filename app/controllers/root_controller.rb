class RootController < ApplicationController
  allow_unauthenticated_access only: :index
  before_action :set_user_by_cookie, except: :index

  def index
  end

  def dash
    @teams = @user.teams
    # redirect_to team_path(team_prefix: @teams.first.prefix) if @teams.length == 1
  end

  private
    def set_user_by_cookie
      @user = find_session_by_cookie.user
    end
end
