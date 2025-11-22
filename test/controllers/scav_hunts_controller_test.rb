require "test_helper"

class ScavHuntControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! Rails.configuration.scavinator_domain
  end

  test "should block unauthenticated" do
    get scav_hunts_url
    assert_response :redirect
  end

  test "should block non-admin" do
    create_test_session users(:one)
    get scav_hunts_url
    assert_response :redirect
  end

  test "should allow admin" do
    create_test_session users(:admin)
    get scav_hunts_url
    assert_response :success
  end

  test "should get show" do
    create_test_session users(:admin)
    get scav_hunt_url(scav_hunts(:one))
    assert_response :success
  end

  test "should get new" do
    create_test_session users(:admin)
    get new_scav_hunt_url
    assert_response :success
  end

  test "should post create" do
    create_test_session users(:admin)
    assert_difference("ScavHunt.count") do
      post url_for(controller: :scav_hunts, action: :create), params: {scav_hunt: {slug: "foobar", start: DateTime.new, end: DateTime.new, name: "FooBar"}}
      assert_response :redirect
    end
  end
end
