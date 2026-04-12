class Team::ScavHunt::ItemsController < Team::ScavHunt::Item::BaseController
  skip_before_action :set_item, only: [:index, :index_mine, :new, :create, :search]
  allow_authcode_access only: %i[index show]

  def index
    items = @team_scav_hunt.items.order(:list_category_id, 'page_number ASC NULLS FIRST', :number).left_joins(:list_category)
    @items_by_category_by_page = items.chunk { |i| i.list_category&.name || :nil }.map { |c, ps| [c, ps.chunk { |p| p.page_number || :nil }] }
  end

  def index_mine
    @items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id}).order(:number)
  end

  def new
    @list_categories = ListCategory.where(team_id: [nil, @team.id])
    @tags = @team.team_tags.where(enabled: true)
  end

  def create
    item_params = params.require(:item).permit(:number, :page_number, :content, :list_category_id, tags: [])
    item = Item.transaction do
      item = @team_scav_hunt.items.create(item_params.slice(:number, :page_number, :content, :list_category_id))
      if item_params[:tags]
        tags = @team.team_tags.where(id: item_params[:tags], enabled: true)
        not_found_ids = item_params[:tags].to_set - tags.map(&:id).map(&:to_s).to_set
        if not_found_ids.size != 0
          raise ActiveRecord::RecordNotFound, "TeamTags not found with ids: #{not_found_ids}"
        end
        item.item_tags.create(tags.map { |tag| {item_id: item.id, team_tag_id: tag.id}})
      end
      item
    end
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *item.for_url)
  end

  def edit
  end

  def update
    if @team_user.captain
      item_params = params.require(:item).permit(:number, :page_number, :content, :discord_thread_id)
    else
      item_params = params.require(:item).permit(:number, :page_number, :content)
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
