require "test_helper"

class Team::Users::CaptainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @captain_teamuser = @team.team_users.find_by(captain: true)
    @noncaptain_teamuser = @team.team_users.find_by(captain: false)
  end

  test "should block noncaptain index" do
    create_team_test_session @team, @noncaptain_teamuser.user
    get team_users_captains_url(@team)
    assert_response :not_found
  end

  test "should add captain" do
    create_team_test_session @team, @captain_teamuser.user
    get team_users_captains_url(@team)
    assert_response :success
    assert_select_has_value "team_user[id]", @noncaptain_teamuser.id
    post team_users_captains_url(@team), params: {team_user: {id: @noncaptain_teamuser.id}}
    assert_redirected_to team_users_captains_url(@team)
  end

  test "should remove captain" do
    create_team_test_session @team, @captain_teamuser.user
    assert_difference -> { @team.team_users.where(captain: true).count }, -1 do
      delete team_users_captain_url(@captain_teamuser, domain: @team.to_domain, subdomain: false)
      assert_redirected_to team_users_captains_url(@team)
    end
  end
end
