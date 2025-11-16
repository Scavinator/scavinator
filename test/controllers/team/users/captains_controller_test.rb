require "test_helper"

class Team::Users::CaptainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @captain_user = @team.team_users.find_by(captain: true).user
    @noncaptain_user = @team.team_users.find_by(captain: false).user
  end

  test "should block noncaptain index" do
    create_team_test_session @team, @noncaptain_user
    get team_users_captains_url(@team)
    assert_response :not_found
  end

  test "should get captain index" do
    create_team_test_session @team, @captain_user
    get team_users_captains_url(@team)
    assert_response :success
  end

  test "should add captain" do
    create_team_test_session @team, @captain_user
    post team_users_captains_url(@team), params: {team_user: {user_id: @noncaptain_user.id}}
    assert_redirected_to team_users_captains_url(@team)
  end

  test "should remove captain" do
    create_team_test_session @team, @captain_user
    delete team_users_captain_url(@captain_user, domain: @team.to_domain, subdomain: false)
    assert_redirected_to team_users_captains_url(@team)
  end
end
