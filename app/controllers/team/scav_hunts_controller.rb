class Team::ScavHuntsController < Team::ScavHunt::BaseController
  skip_before_action :set_team_scav_hunt, only: [:index, :new, :create]
  require_captain except: [:index, :show]
  allow_authcode_access only: :show

  def index
    @scav_hunts = @team.team_scav_hunts
  end

  def edit
  end

  def update
    @team_scav_hunt.update(params.require(:team_scav_hunt).permit(:name))
    redirect_to team_scav_hunt_path(@team_scav_hunt)
  end

  def show
  end

  def new
    @eligable_scav_hunts = ScavHunt.left_joins(:team_scav_hunts).where.not(team_scav_hunts: {team_id: @team.id}).or(TeamScavHunt.where(team_id: nil))
  end

  def create
    hunt = @team.team_scav_hunts.create(params[:team_scav_hunt].permit(:name, :scav_hunt_id))
    redirect_to team_scav_hunt_path(hunt)
  end
end
