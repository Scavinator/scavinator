class ScavHuntsController < ApplicationController
  before_action :set_user_by_cookie, :require_admin

  def index
    @scav_hunts = ScavHunt.all
  end

  def show
    @scav_hunt = ScavHunt.find(params[:id])
    @teams = @scav_hunt.team_scav_hunts
  end

  def new
  end

  def create
    ScavHunt.create(params[:scav_hunt].permit(:name, :start, :end, :slug))
    redirect_to action: :index
  end

  private
    def set_user_by_cookie
      @user = find_session_by_cookie.user
    end

    def require_admin
      if !@user.admin
        redirect_to new_session_path
      end
    end
end
