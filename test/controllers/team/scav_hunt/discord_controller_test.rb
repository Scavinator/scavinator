require "test_helper"

class Team::ScavHunt::DiscordControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @tsh = @team.team_scav_hunts.first
  end

  test "should get edit" do
    [users(:one_captain), users(:one_captain_discord)].each do |u|
      tsh = u.teams.first.team_scav_hunts.first
      team = tsh.team
      assert_captain(team, -> { get edit_team_scav_hunt_discord_url(tsh) }, captain_user: u) do
        assert_response :success
      end
    end
  end

  # test "should get update" do
  #   get team_scav_hunt_discord_update_url
  #   assert_response :success
  # end
end
