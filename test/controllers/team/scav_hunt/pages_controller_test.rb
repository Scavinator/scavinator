require "test_helper"

class Team::ScavHunt::PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @tsh = @team.team_scav_hunts.first
    @captain_user = @team.team_users.find_by(captain: true).user
    @noncaptain_user = @team.team_users.find_by(captain: false).user
    @valid_page_number = Page.find_by(team_scav_hunt_id: @tsh.id).page_number
  end

  test "should get show" do
    create_team_test_session @team, @noncaptain_user
    get team_scav_hunt_page_url(@tsh, 68138) # invalid page
    assert_response :not_found
    get team_scav_hunt_page_url(@tsh, @valid_page_number)
    assert_response :success
  end

  test "should block write for scavvie" do
    create_team_test_session @team, @noncaptain_user
    get new_team_scav_hunt_page_url(@tsh)
    assert_response :not_found
    assert_no_difference -> { PageCaptain.count } do
      post team_scav_hunt_pages_url, params: {}
      assert_response :not_found
    end
    assert_no_difference -> { PageCaptain.count } do
      delete team_scav_hunt_page_url(@tsh, @valid_page_number)
      assert_response :not_found
    end
  end

  test "should allow write for captain" do
    create_team_test_session @team, @captain_user
    get new_team_scav_hunt_page_url(@tsh)
    assert_response :success
    assert_difference -> { PageCaptain.count } do
      post team_scav_hunt_pages_url, params: {page_captain: {page_number: 123, user_id: users(:one).id}}
      assert_redirected_to team_scav_hunt_page_url(@tsh, 123)
    end
    assert_difference -> { PageCaptain.count }, -1 do
      delete team_scav_hunt_page_url(@tsh, @valid_page_number), params: {page_captain: {user_id: users(:one).id}}
      assert_response :redirect
    end
  end

  # TODO: Add tests for require_page_owner
end
