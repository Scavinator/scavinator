# NOTE: Inherits from Item::BaseController in order to utilize set_item
class Team::ScavHunt::EventsController < Team::ScavHunt::Item::BaseController
  before_action :set_event, only: [:destroy]
  skip_before_action :set_item, only: [:index]
  allow_authcode_access only: [:index]

  def destroy
    @event.delete
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def create
    @item.item_events.create! params.expect(item_event: [:date])
    redirect_to team_scav_hunt_item_path(@team_scav_hunt, *@item.for_url)
  end

  def index
    @events = @team_scav_hunt.item_events.order(:date)
  end

  private
    def set_event
      @event = @item.item_events.find(request.path_parameters[:id])
    end
end
