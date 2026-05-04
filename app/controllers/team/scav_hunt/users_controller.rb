class Team::ScavHunt::UsersController < Team::ScavHunt::BaseController
  def show
    @user = User.find(params[:id])
    @items = @team_scav_hunt.items.joins(:item_users).where(item_users: {user_id: @user.id}).order(:number)
  end
end
