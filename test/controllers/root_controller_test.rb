require "test_helper"

class RootControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_root_url
    assert_response :success
  end

  test "should get redirected if logged out" do
    get root_dash_url
    assert_redirected_to new_session_url
  end

  test "should show dash if logged in" do
    create_test_session users.first
    get root_dash_url
    assert_response :success
  end
end
