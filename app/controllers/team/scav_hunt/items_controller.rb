class Team::ScavHunt::ItemsController < Team::ScavHunt::Item::BaseController
  skip_before_action :set_item, only: [:index, :index_mine, :new, :create, :search, :by_category, :item_wizard_page]
  allow_authcode_access only: %i[index show]

  def index
    chunk_items_page @team_scav_hunt.items.order(:list_category_id, 'page_number ASC NULLS FIRST', :number).eager_load(:list_category, :item_users, :item_events, :item_submission).preload(:team_tags)
    # @items_by_category_by_page = items.chunk { |i| i.list_category&.name || :nil }.map { |c, ps| [c, ps.chunk { |p| p.page_number || :nil }] }
  end

  def by_category
    category = ListCategory.where(team_id: [nil, @team.id]).find_by!(slug: request.path_parameters[:category_slug])
    @skip_header = true
    chunk_items_page @team_scav_hunt.items.where(list_category: category).order(:number).all
  end

  def index_mine
    @items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id}).order(:number)
  end

  def new
    @list_categories = ListCategory.where(team_id: [nil, @team.id]).order(:id)
    @tags = @team.team_tags.where(enabled: true)
    @item = @team_scav_hunt.items.new
  end

  def create
    item_fields = [*base_item_fields]
    item_params = params.require(:item).permit(*item_fields, :timed_calendar, team_tags: [])
    item = Item.transaction do
      item = @team_scav_hunt.items.create!(**item_params.slice(*item_fields),
        digital_submission: item_params[:digital_submission] == "1",
        special_formatting: item_params[:special_formatting] == "1"
      )
      if item_params[:timed_calendar].present?
        item.item_events.create(date: item_params[:timed_calendar])
      end
      if item_params[:team_tags]
        tags = @team.team_tags.where(id: item_params[:team_tags], enabled: true)
        not_found_ids = item_params[:team_tags].to_set - tags.map(&:id).map(&:to_s).to_set
        if not_found_ids.size != 0
          raise ActiveRecord::RecordNotFound, "TeamTags not found with ids: #{not_found_ids}"
        end
        item.item_tags.create(tags.map { |tag| {item_id: item.id, team_tag_id: tag.id}})
      end
      item
    end
  rescue ActiveRecord::RecordInvalid => r
    if r.record.is_a? Item
      new
      @item = r.record
      if params[:format] == "json"
        render json: @item.errors.full_messages, status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    else
      raise
    end
  else
    if params[:format] == "json"
      render json: item_wizard_json(item)
    else
      redirect_to team_scav_hunt_item_path(@team_scav_hunt, *item.for_url)
    end
  end

  def item_wizard_page
    render json: (@team_scav_hunt.items.where(page_number: params[:page_number].empty? ? nil : params[:page_number], list_category_id: params[:list_category_id].empty? ? nil : params[:list_category_id]).eager_load(:list_category).preload(:team_tags).map { |i| item_wizard_json(i) })
  end

  def edit
    @list_categories = ListCategory.where(team_id: [nil, @team.id])
  end

  def update
    if @team_user.captain
      item_params = params.require(:item).permit(*base_item_fields, :discord_thread_id)
    else
      item_params = params.require(:item).permit(*base_item_fields)
    end
    @item.update(**item_params.slice(*base_item_fields),
      digital_submission: item_params[:digital_submission] == "1",
      special_formatting: item_params[:special_formatting] == "1"
    )
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def show
    @files = ItemFile.where(item: @item)
    if @item.item_submission
      @files = @files.order(item_id: :desc)
    end
    @tags = @team.team_tags.where(enabled: true).all
    @team_users = @team.team_users.where(approved: true).all
    @events = @item.item_events.all.order(:date)
    @next_event = @events.select { |e| e.date > Time.current }.first || @events.last
  end

  def search
    # TODO: implement
  end

  private
    def base_item_fields
      %i[number page_number content points_text points_value digital_submission special_formatting list_category_id]
    end

    def chunk_items_page(items)
      @items_by_category_by_page = items.chunk { |i| i.list_category || :nil }.map { |c, ps| [c, ps.chunk { |p| p.page_number || :nil }] }
      render "index"
    end

    def item_wizard_json(item)
      finish_path = nil
      if item.list_category
        finish_path = team_scav_hunt_category_path(@team_scav_hunt, item.list_category)
      elsif item.page_number
        finish_path = team_scav_hunt_page_path(@team_scav_hunt, item.page_number)
      end
      {
        **item.slice(:page_number, :number, :content, :points_text, :points_value),
        path: team_scav_hunt_item_path(@team_scav_hunt, *item.for_url),
        finish_path: finish_path,
        team_tags: item.team_tags.map { |t| t.slice(:name, :color) }
      }
    end
end
