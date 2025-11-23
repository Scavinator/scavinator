require "test_helper"

class Team::ScavHunt::DiscordControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @tsh = @team.team_scav_hunts.first
  end

  test "should get edit" do
    assert_captain(@team, -> { get edit_team_scav_hunt_discord_url(@tsh) }) do
      assert_response :success
    end
  end

  # test "should get update" do
  #   get team_scav_hunt_discord_update_url
  #   assert_response :success
  # end
end
