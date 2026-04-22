class Team::TagsController < Team::BaseController
  require_captain

  def index
    @tags = @team.team_tags.where(enabled: true)
  end

  def edit
    @tag = @team.team_tags.find(params[:id])
    @roles = @team.team_roles.where(enabled: true)
  end

  def update
    @team.team_tags.find(params[:id]).update(params[:team_tag].permit(:name, :color, :enabled, :team_role_id, :requires_approval))
    redirect_to action: :index
  end

  def new
  end

  def create
    @team.team_tags.create params.expect(team_tag: [:name, :color, :requires_approval])
    redirect_to action: :index
  end
end
