require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_url
    assert_response :success
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
