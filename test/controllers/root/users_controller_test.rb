require "test_helper"

class Root::UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get root_users_new_url
    assert_response :success
  end

  test "should get create" do
    get root_users_create_url
    assert_response :success
  end
end
