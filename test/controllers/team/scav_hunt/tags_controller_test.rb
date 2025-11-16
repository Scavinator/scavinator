require "test_helper"

class Team::ScavHunt::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    create_team_test_session @tsh.team, users(:one)
  end

  test "should get show" do
    get team_scav_hunt_tag_url(@tsh, @tsh.team.team_tags.first)
    assert_response :success
  end

  # TODO: Should test tag ownership stuff but wont
end
