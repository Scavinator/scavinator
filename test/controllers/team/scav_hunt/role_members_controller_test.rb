require "test_helper"

class Team::ScavHunt::RoleMembersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_scav_hunt_role_members_index_url
    assert_response :success
  end

  test "should get create" do
    get team_scav_hunt_role_members_create_url
    assert_response :success
  end

  test "should get delete" do
    get team_scav_hunt_role_members_delete_url
    assert_response :success
  end
end
