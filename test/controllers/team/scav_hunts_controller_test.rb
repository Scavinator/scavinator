require "test_helper"

class Team::ScavHuntsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @captain_user = @team.team_users.find_by(captain: true).user
    @noncaptain_user = @team.team_users.find_by(captain: false).user
  end

  test "should get index" do
    create_team_test_session @team, @noncaptain_user
    get team_scav_hunts_url
    assert_response :success
  end

  test "should get show" do
    create_team_test_session @team, @noncaptain_user
    tsh = @team.team_scav_hunts.first
    get team_scav_hunt_url(tsh)
    assert_response :success
  end

  test "should block normal scavvie create" do
    create_team_test_session @team, @noncaptain_user
    get new_team_scav_hunt_url
    assert_response :not_found
    assert_no_difference("TeamScavHunt.count") do
      post url_for(TeamScavHunt.new), params: {team_scav_hunt: {name: "ScavTeam", scav_hunt_id: scav_hunts(:two).id}}
      assert_response :not_found
    end
  end

  test "should allow captain create" do
    create_team_test_session @team, @captain_user
    get new_team_scav_hunt_url
    assert_response :success
    assert_difference("TeamScavHunt.count") do
      post url_for(TeamScavHunt.new), params: {team_scav_hunt: {name: "ScavTeam", scav_hunt_id: scav_hunts(:two).id}}
      assert_redirected_to team_scav_hunt_url(TeamScavHunt.last)
    end
  end

  test "should block edit for normal scavvie" do
    create_team_test_session @team, @noncaptain_user
    get edit_team_scav_hunt_url(@team.team_scav_hunts.first.scav_hunt)
    assert_response :not_found
  end

  test "should allow captain edit" do
    create_team_test_session @team, @captain_user
    tsh = @team.team_scav_hunts.first
    get edit_team_scav_hunt_url(tsh)
    assert_response :success
    # TODO: There is no normal way to edit a team_scav_hunt, like change the name or something.
    #       Either these routes should be renamed to be about discord and separate routes for
    #       normal editing should be added, or these should also allow editing the team.
    #       Unrelated, but also you should not be able to do "Team Registration" from team_scav_hunt#show
    #       and the like, or at the very least that nav option should be named much better
    #       And finally, you should mock the discord API responses and finish this test
    #       https://www.rubydoc.info/gems/minitest/Minitest/Mock
    new_name = "ScavTeamNewName"
    assert_changes(-> { tsh.reload.name }, from: tsh.name, to: new_name) do
      patch team_scav_hunt_url(tsh), params: {team_scav_hunt: {name: new_name, scav_hunt_id: scav_hunts(:two).id}}
      assert_response :success
    end
  end
end
