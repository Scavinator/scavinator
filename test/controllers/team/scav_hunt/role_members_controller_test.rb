require "test_helper"

class Team::ScavHunt::RoleMembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @tsh = @team.team_scav_hunts.first
  end

  test "should get index" do
    assert_captain(@team, -> { get team_scav_hunt_role_members_url(@tsh) },
      captain_assert: -> { assert_response :success },
      scavvie_assert: -> { assert_response :success })
  end

  test "should create" do
    assert_captain(@team, -> { post team_scav_hunt_role_members_url(@tsh), params: {team_role_member: {team_role_id: @team.team_roles.first.id, user_id: @team.team_users.first.id}} }) do
      assert_redirected_to team_scav_hunt_role_members_url(@tsh)
    end
  end

  test "should delete" do
    assert_captain(@team, -> { delete team_scav_hunt_role_member_url(@tsh, TeamRoleMember.find_by(team_scav_hunt_id: @tsh.id)) }) do
      assert_redirected_to team_scav_hunt_role_members_url(@tsh)
    end
  end
end
