require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should get edit" do
    team = Team.first
    user = team.users.first
    get edit_user_url(user)
    assert_redirected_to new_session_url
    [users(:one_captain), users(:one_captain_discord)].each do |u|
      reset!
      create_team_test_session u.teams.first, u
      get edit_user_url(u, domain: Rails.configuration.scavinator_domain)
      assert_response :success
    end
  end

  test "should get create" do
    assert_difference("Team.count") do
      post url_for(User.new), params: {
        type: :scavvie,
        user_name: "foobar",
        email_address: "foo@bar.com",
        password: "secret",
        password_again: "secret",
        affiliation: "someaffiliation",
        prefix: "newteam",
      }
      assert_response :redirect
    end
  end

  test "should fail on invalid prefix" do
    assert_no_difference("Team.count") do
      post url_for(User.new), params: {
        type: :scavvie,
        user_name: "foobar",
        email_address: "foo@bar.com",
        password: "secret",
        password_again: "secret",
        affiliation: "someaffiliation",
        prefix: "new team",
      }
      assert_400_error
    end
  end
end
