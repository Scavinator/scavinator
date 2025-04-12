require "test_helper"

class Team::ScavHunt::ItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_scav_hunt_items_index_url
    assert_response :success
  end

  test "should get new" do
    get team_scav_hunt_items_new_url
    assert_response :success
  end

  test "should get edit" do
    get team_scav_hunt_items_edit_url
    assert_response :success
  end

  test "should get show" do
    get team_scav_hunt_items_show_url
    assert_response :success
  end
end
