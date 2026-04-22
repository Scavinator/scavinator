require "test_helper"

class Team::ScavHunt::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = item_events(:one)
    @item = @event.item
    @tsh = @item.team_scav_hunt
    @team = @tsh.team
  end

  test "should delete" do
    assert_difference -> { ItemEvent.count }, -1 do
      assert_scavvie @team, -> { delete team_scav_hunt_item_event_url(@tsh, *@item.for_url, @event) } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
      end
    end
  end

  test "should create" do
    assert_difference -> { ItemEvent.count }, 1 do
      assert_scavvie @team, -> { post team_scav_hunt_item_events_url(@tsh, *@item.for_url), params: {item_event: {date: Date.new}} } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
      end
    end
  end
end
