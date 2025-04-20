class Team::ScavHunt::TagsController < Team::ScavHunt::BaseController
  include Team::ScavHuntsHelper

  def show
    @tag = @team.team_tags.find(params[:id])
    if owns_tag? @tag
      @pending_items = @team_scav_hunt.items.joins(:team_tags).joins(:item_tags).where(team_tags: {id: params[:id]}, item_tags: {accepted: nil})
    end
    @items = @team_scav_hunt.items.joins(:team_tags).joins(:item_tags).where(team_tags: {id: params[:id]}, item_tags: {accepted: true})
  end
end
