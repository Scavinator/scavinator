class Team::ScavHunt::ItemsController < Team::ScavHunt::Item::BaseController
  skip_before_action :set_item, only: [:index, :index_mine, :new, :create, :search]

  def index
    @items_by_page = @team_scav_hunt.items.group_by(&:page_number)
  end

  def index_mine
    @items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id})
  end

  def new
  end

  def create
    item = @team_scav_hunt.items.create(params[:item].permit(:number, :page_number, :content))
    redirect_to action: :show, id: item.id
  end

  def edit
  end

  def update
    item = @item.update(params[:item].permit(:number, :page_number, :content))
    redirect_to action: :show, id: params[:id]
  end

  def show
    @tags = @team.team_tags.where(enabled: true).all
    @team_users = @team.team_users.where(approved: true).all
  end

  def search
    # TODO: implement
  end
end
