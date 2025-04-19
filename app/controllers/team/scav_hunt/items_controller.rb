class Team::ScavHunt::ItemsController < Team::ScavHunt::Item::BaseController
  skip_before_action :set_item, only: [:index, :index_mine, :new, :create, :search]

  def index
    items = @team_scav_hunt.items.order(:list_category_id, 'page_number ASC NULLS FIRST', :number).left_joins(:list_category)
    @items_by_category_by_page = items.chunk { |i| i.list_category&.name || :nil }.map { |c, ps| [c, ps.chunk { |p| p.page_number || :nil }] }
  end

  def index_mine
    @items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id}).order(:number)
  end

  def new
    @list_categories = ListCategory.where(team_id: [nil, @team.id])
  end

  def create
    item = @team_scav_hunt.items.create(params[:item].permit(:number, :page_number, :content, :list_category_id))
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *item.for_url)
  end

  def edit
  end

  def update
    if @team_user.captain
      item_params = params[:item].permit(:number, :page_number, :content, :discord_thread_id)
    else
      item_params = params[:item].permit(:number, :page_number, :content)
    end
    @item.update(item_params)
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def show
    @tags = @team.team_tags.where(enabled: true).all
    @team_users = @team.team_users.where(approved: true).all
  end

  def search
    # TODO: implement
  end
end
