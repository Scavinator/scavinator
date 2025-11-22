require "test_helper"

class Team::ScavHuntsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @tsh = @team.team_scav_hunts.first
    @noncaptain_user = @team.team_users.find_by(captain: false).user
  end

  test "should get index" do
    create_team_test_session @team, @noncaptain_user
    get team_scav_hunts_url
    assert_response :success
  end

  test "should get show" do
    create_team_test_session @team, @noncaptain_user
    get team_scav_hunt_url(@tsh)
    assert_response :success
  end

  test "should get create" do
    assert_captain(@team, -> { get new_team_scav_hunt_url }) do
      assert_response :success
      assert_difference("TeamScavHunt.count") do
        post url_for(TeamScavHunt.new), params: {team_scav_hunt: {name: "ScavTeam", scav_hunt_id: scav_hunts(:two).id}}
        assert_redirected_to team_scav_hunt_url(TeamScavHunt.last)
      end
    end
  end

  test "should get edit discord" do
    assert_captain(@team, -> { get edit_team_scav_hunt_discord_url(@tsh) }) do
      assert_response :success
    end
  end

  test "should get edit" do
    assert_captain(@team, -> { get edit_team_scav_hunt_url(@tsh) }) do
      assert_response :success
    end
  end

  test "should post edit" do
    # TODO: Unrelated, but also you should not be able to do "Team Registration" from team_scav_hunt#show
    #       and the like, or at the very least that nav option should be named much better
    #       And finally, you should mock the discord API responses and finish this test
    #       https://www.rubydoc.info/gems/minitest/Minitest/Mock
    new_name = "ScavTeamNewName"
    assert_changes(-> { @tsh.reload.name }, from: @tsh.name, to: new_name) do
      assert_captain(@team, -> { patch team_scav_hunt_url(@tsh), params: {team_scav_hunt: {name: new_name, scav_hunt_id: scav_hunts(:two).id}} }) do
        assert_redirected_to team_scav_hunt_url(@tsh)
      end
    end
  end
end
