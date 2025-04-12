class Team::RolesController < Team::BaseController
  def new
  end

  def create
    role = @team.team_roles.create(params[:team_role].permit(:name))
    redirect_to team_role_path(@team, role)
  end

  def show
    @role = @team.team_roles.find(params[:id])
  end

  def edit
    @role = @team.team_roles.find(params[:id])
  end

  def update
    role = @team.team_roles.find(params[:id])
    role.update(name: params[:team_role][:name], enabled: params[:team_role][:enabled].present?)
    redirect_to team_roles_path(@team)
  end

  def index
    @roles = @team.team_roles.where(enabled: true)
  end
end
