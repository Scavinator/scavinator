require "test_helper"

class Team::Users::CaptainsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_users_captains_index_url
    assert_response :success
  end
end
