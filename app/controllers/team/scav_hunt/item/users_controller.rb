class Team::ScavHunt::Item::UsersController < Team::ScavHunt::Item::BaseController
  def edit
  end

  def update
  end

  def create # assign
    # TODO: can be done by cap, page cap, or self
    user = @team.team_users.where(approved: true).find(params[:item_user][:user_id]).user
    @item.item_users.create(user_id: user.id)
    redirect_to team_scav_hunt_item_path(@team, @team_scav_hunt, @item)
  end

  def destroy # unassign
    # TODO: can be done by cap, page cap, or self
    @item.item_users.find(params[:item_user][:id]).delete
    redirect_to team_scav_hunt_item_path(@team, @team_scav_hunt, @item)
  end
end
