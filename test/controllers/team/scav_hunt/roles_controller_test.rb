require "test_helper"

class Team::ScavHunt::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
    @role = @team.team_roles.first
    @captain_user = @team.team_users.find_by!(captain: true).user
    @noncaptain_user = @team.team_users.find_by!(captain: false).user
    create_team_test_session @team, @noncaptain_user
  end

  test "should get show" do
    get team_scav_hunt_role_url(@tsh, @role)
    assert_response :success
  end
end
