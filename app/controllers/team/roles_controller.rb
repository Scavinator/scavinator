class Team::RolesController < Team::BaseController
  require_captain except: [:index, :show]
  before_action :set_role, only: [:show, :edit, :update]

  def new
  end

  def create
    role = @team.team_roles.create(params.require(:team_role).permit(:name))
    redirect_to team_role_path(role)
  end

  def show
    @role_members_by_year = TeamRoleMember.joins(:team_scav_hunt).where(team_scav_hunt: {team_id: @team.id}, team_role_id: @role.id).order(:team_scav_hunt_id).group_by(&:team_scav_hunt)
  end

  def edit
  end

  def update
    @role.update(name: params.require(:team_role).require(:name), enabled: params.require(:team_role)[:enabled].present?)
    redirect_to team_roles_path
  end

  def index
    @roles = @team.team_roles.where(enabled: true)
  end

  private
    def set_role
      @role = @team.team_roles.find(request.path_parameters[:id])
    end
end
