require "test_helper"

class Team::ScavHunt::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
  end

  test "should get show" do
    assert_authcode @team, -> { get team_scav_hunt_tag_url(@tsh, @team.team_tags.first) } do
      assert_response :success
    end
  end

  # TODO: Should test tag ownership stuff but wont
end
