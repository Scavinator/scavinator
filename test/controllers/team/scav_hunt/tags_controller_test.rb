require "test_helper"

class Team::ScavHunt::TagsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get team_scav_hunt_tags_show_url
    assert_response :success
  end
end
