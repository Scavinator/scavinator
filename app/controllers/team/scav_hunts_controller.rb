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
    @team_scav_hunt.update(params.expect(team_scav_hunt: [:name, :digital_submission_link]))
    redirect_to team_scav_hunt_path(@team_scav_hunt)
  end

  def show
    # TODO: This is highly hacky and will need to be reworked post scav 2026
    @pins = @team_scav_hunt.team.team_tags.where.not(pinned: nil).order(:pinned).all.map { |tag| [tag, @team_scav_hunt.items.joins(:item_tags).where(item_tags: {team_tag_id: tag.id}).order(:number)] }
    @hq_pin = @pins.shift
    showcase_category = ListCategory.find_by(name: "Showcase")
    @showcase = @team_scav_hunt.items.joins(:item_users).where(list_category_id: showcase_category.id).order(:number) unless showcase_category.nil?
    @events = @team_scav_hunt.item_events.order(:date).where("date > ?", DateTime.now).limit(5)
  end

  def new
    @eligable_scav_hunts = ScavHunt.left_joins(:team_scav_hunts).where.not(team_scav_hunts: {team_id: @team.id}).or(TeamScavHunt.where(team_id: nil))
  end

  def create
    hunt = @team.team_scav_hunts.create(params[:team_scav_hunt].permit(:name, :scav_hunt_id))
    redirect_to team_scav_hunt_path(hunt)
  end
end
