require "test_helper"

class Team::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @captain_user = @team.team_users.find_by(captain: true).user
    @noncaptain_user = @team.team_users.find_by(captain: false).user
  end

  test "should get index" do
    create_team_test_session @team, @noncaptain_user
    get team_users_url
    assert_response :success
  end

  test "should block admin indicies for regular scavvies" do
    create_team_test_session @team, @noncaptain_user
    get team_users_pending_url
    assert_response :not_found
    get team_users_banned_url
    assert_response :not_found
    post team_user_url(@team.team_users.first)
    assert_response :not_found
  end

  test "should allow admin indicies for captains" do
    create_team_test_session @team, @captain_user
    get team_users_pending_url
    assert_response :success
    get team_users_banned_url
    assert_response :success
  end

  test "should post update" do
    create_team_test_session @team, @captain_user
    # TODO: Lotta problems here. First is the schema of team_users. It says approved is NOT NULL
    #       but this code clearly plans on NULL values. Need to figure that out. And also what is
    #       the invited column even for? There is no even moderately thought out invitation system?
    patch team_user_url(@team.team_users.find_by(approved: nil).first)
    assert_redirected_to team_users_url
  end
end
