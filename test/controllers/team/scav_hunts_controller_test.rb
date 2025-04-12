require "test_helper"

class Team::ScavHuntsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_scav_hunts_index_url
    assert_response :success
  end

  test "should get show" do
    get team_scav_hunts_show_url
    assert_response :success
  end

  test "should get new" do
    get team_scav_hunts_new_url
    assert_response :success
  end

  test "should get create" do
    get team_scav_hunts_create_url
    assert_response :success
  end
end
