require "test_helper"

class Team::ScavHunt::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
  end

  test "should get show" do
    assert_scavvie @team, -> { get team_scav_hunt_user_url(@tsh, @team.team_users.first.user) } do
      assert_response :success
    end
  end
end
