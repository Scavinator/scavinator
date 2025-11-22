require "test_helper"

class Team::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
  end

  test "should get index" do
    assert_scavvie @team, -> { get team_users_url } do
      assert_response :success
    end
  end

  test "should allow admin indicies for captains" do
    assert_captain @team, -> { get team_users_pending_url } do
      assert_response :success
    end
    assert_captain @team, -> { get team_users_banned_url } do
      assert_response :success
    end
  end

  test "should post update" do
    assert_captain @team, -> { patch team_user_url(@team.team_users.find_by!(approved: nil)), params: {team_user: {approved: "true"}} } do
      assert_redirected_to team_users_url
    end
  end

  test "should fail on invalid approved value update" do
    [nil, "abc", ""].each do |v|
      assert_captain @team, -> { patch team_user_url(@team.team_users.find_by!(approved: nil)), params: {team_user: {approved: v}} } do
        assert_400_error
      end
    end
    assert_captain @team, -> { patch team_user_url(@team.team_users.find_by!(approved: nil)), params: {team_user: nil} } do
      assert_400_error
    end
  end
end
