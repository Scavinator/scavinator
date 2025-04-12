require "test_helper"

class ScavHuntControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get scav_hunt_index_url
    assert_response :success
  end

  test "should get show" do
    get scav_hunt_show_url
    assert_response :success
  end

  test "should get new" do
    get scav_hunt_new_url
    assert_response :success
  end

  test "should get create" do
    get scav_hunt_create_url
    assert_response :success
  end
end
