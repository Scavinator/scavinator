class Team::TagsController < Team::BaseController
  before_action :require_captain

  def index
    @tags = @team.team_tags.where(enabled: true)
  end

  def edit
    @tag = @team.team_tags.find(params[:id])
    @roles = @team.team_roles.where(enabled: true)
  end

  def update
    @team.team_tags.find(params[:id]).update(params[:team_tag].permit(:name, :color, :enabled, :team_role_id))
    redirect_to action: :index
  end

  def new
  end

  def create
    @team.team_tags.create(params[:team_tag].permit(:name, :color))
    redirect_to action: :index
  end
end
