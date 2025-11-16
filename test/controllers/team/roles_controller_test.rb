require "test_helper"

class Team::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @captain_user = @team.team_users.find_by(captain: true).user
    @noncaptain_user = @team.team_users.find_by(captain: false).user
  end

  test "should get create" do
    create_team_test_session @team, @captain_user
    get new_team_role_url
    assert_response :success
    assert_difference -> { TeamRole.count } do
      post team_roles_url, params: {team_role: {name: "TestRole"}}
      assert_response :redirect
    end
  end

  test "should get update" do
    create_team_test_session @team, @captain_user
    get edit_team_role_url(@team.team_roles.first)
    assert_response :success
    tr = @team.team_roles.first
    new_name = "TestRoleNewName"
    assert_changes -> { tr.reload.name }, from: tr.name, to: new_name do
      patch team_role_url(tr), params: {team_role: {name: new_name}}
      assert_response :redirect
    end
  end

  test "should get normal scavvie routes" do
    create_team_test_session @team, @noncaptain_user
    get team_roles_url
    assert_response :success
    get team_role_url(@team.team_roles.first)
    assert_response :success
    get edit_team_role_url(@team.team_roles.first)
    assert_response :not_found
    get new_team_role_url
    assert_response :not_found
  end

  test "should block index" do
    get team_roles_url(domain: @team.to_domain, subdomain: false)
    assert_response :redirect
  end
end
