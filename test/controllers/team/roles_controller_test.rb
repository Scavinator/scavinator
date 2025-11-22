require "test_helper"

class Team::RolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
  end

  test "should get create" do
    assert_captain(@team, -> { get new_team_role_url }) do
      assert_response :success
    end
    assert_difference -> { TeamRole.count } do
      assert_captain(@team, -> { post team_roles_url, params: {team_role: {name: "TestRole"}} }) do
        assert_response :redirect
      end
    end
  end

  test "should get update" do
    assert_captain(@team, -> { get edit_team_role_url(@team.team_roles.first) }) do
      assert_response :success
    end
    tr = @team.team_roles.first
    new_name = "TestRoleNewName"
    assert_changes -> { tr.reload.name }, from: tr.name, to: new_name do
      assert_captain(@team, -> { patch team_role_url(tr), params: {team_role: {name: new_name}} }) do
        assert_response :redirect
      end
    end
  end

  test "should get normal scavvie routes" do
    assert_scavvie(@team, -> { get team_roles_url }) do
      assert_response :success
    end
    assert_scavvie(@team, -> { get team_role_url(@team.team_roles.first) }) do
      assert_response :success
    end
  end
end
