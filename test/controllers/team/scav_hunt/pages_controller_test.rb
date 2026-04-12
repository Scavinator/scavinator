require "test_helper"

class Team::ScavHunt::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @tsh = @team.team_scav_hunts.first
    @valid_page_number = Page.find_by(team_scav_hunt_id: @tsh.id).page_number
  end

  test "should get show" do
    assert_authcode @team, -> { get team_scav_hunt_page_url(@tsh, 68138) } do # invalid page
      assert_response :not_found
    end
    assert_authcode @team, -> { get team_scav_hunt_page_url(@tsh, @valid_page_number) } do
      assert_response :success
    end
  end

  test "should allow write for captain" do
    assert_captain @team, -> { get new_team_scav_hunt_page_url(@tsh) } do
      assert_response :success
    end
    assert_difference -> { PageCaptain.count } do
      assert_captain @team, -> { post team_scav_hunt_pages_url(@tsh), params: {page_captain: {page_number: 123, user_id: users(:one).id}} } do
        assert_redirected_to team_scav_hunt_page_url(@tsh, 123)
      end
    end
    assert_difference -> { PageCaptain.count }, -1 do
      assert_captain @team, -> { delete team_scav_hunt_page_url(@tsh, @valid_page_number), params: {page_captain: {user_id: users(:one).id}} } do
        assert_response :redirect
      end
    end
  end

  # TODO: Add tests for require_page_owner
end
