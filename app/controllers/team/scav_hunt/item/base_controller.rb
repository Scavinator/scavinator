class Team::ScavHunt::Item::BaseController < Team::ScavHunt::BaseController
  before_action :set_item

  private
    def set_item
      @item = @team_scav_hunt.items.find_by!(id: params[:item_id])
    end
end
