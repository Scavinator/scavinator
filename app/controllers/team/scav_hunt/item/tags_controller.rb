class Team::ScavHunt::Item::TagsController < Team::ScavHunt::Item::BaseController
  def create
    tag = @team.team_tags.where(enabled: true).find(params[:item_tag][:tag_id])
    @item.item_tags.create(team_tag_id: tag.id)
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def destroy
    # TODO: can't remove approved role tags unless page cap/cap/role member
    @item.item_tags.find(params[:item_tag_id]).delete
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def approve
    tag = ItemTag.joins(:team_tag).find_by!(id: params[:item_tag_id], team_tag: {team_id: @team.id}).team_tag
    render nothing: true, status: 403 unless owns_tag? tag
    @item.item_tags.find(params[:item_tag_id]).update(accepted: true)
    redirect_back fallback_location: team_scav_hunt_tag_path(@team_scav_hunt, tag)
  end
end
