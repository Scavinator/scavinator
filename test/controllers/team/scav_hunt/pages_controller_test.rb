require "test_helper"

class Team::ScavHunt::PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_scav_hunt_pages_index_url
    assert_response :success
  end

  test "should get show" do
    get team_scav_hunt_pages_show_url
    assert_response :success
  end

  test "should get new" do
    get team_scav_hunt_pages_new_url
    assert_response :success
  end

  test "should get edit" do
    get team_scav_hunt_pages_edit_url
    assert_response :success
  end
end
