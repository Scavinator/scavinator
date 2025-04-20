require "test_helper"

class Team::ScavHunt::RolesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get team_scav_hunt_roles_show_url
    assert_response :success
  end
end
