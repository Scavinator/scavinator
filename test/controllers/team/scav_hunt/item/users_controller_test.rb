require "test_helper"

class Team::ScavHunt::Item::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get team_scav_hunt_item_users_edit_url
    assert_response :success
  end
end
