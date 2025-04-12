class Team::ScavHunt::ItemsController < Team::ScavHunt::BaseController
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
    @item = @team_scav_hunt.items.find(params[:id])
  end

  def update
    item = @team_scav_hunt.items.find(params[:id]).update(params[:item].permit(:number, :page_number, :content))
    redirect_to action: :show, id: params[:id]
  end

  def show
    @item = @team_scav_hunt.items.find(params[:id])
    @tags = @team.team_tags.where(enabled: true).all
    @team_users = @team.team_users.where(approved: true).all
  end

  def search
    # TODO: implement
  end
end
