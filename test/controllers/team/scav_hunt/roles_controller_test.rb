require "test_helper"

class Team::ScavHunt::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
    @role = @team.team_roles.first
  end

  test "should get show" do
    assert_scavvie @team, -> { get team_scav_hunt_role_url(@tsh, @role) } do
      assert_response :success
    end
  end
end
