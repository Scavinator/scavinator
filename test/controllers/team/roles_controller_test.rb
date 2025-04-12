require "test_helper"

class Team::RolesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get team_roles_new_url
    assert_response :success
  end

  test "should get create" do
    get team_roles_create_url
    assert_response :success
  end

  test "should get edit" do
    get team_roles_edit_url
    assert_response :success
  end

  test "should get update" do
    get team_roles_update_url
    assert_response :success
  end

  test "should get index" do
    get team_roles_index_url
    assert_response :success
  end
end
