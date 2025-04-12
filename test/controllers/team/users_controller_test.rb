require "test_helper"

class Team::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_users_index_url
    assert_response :success
  end

  test "should get update" do
    get team_users_update_url
    assert_response :success
  end
end
