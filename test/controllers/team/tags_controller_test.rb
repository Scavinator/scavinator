require "test_helper"

class Team::TagsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get team_tags_index_url
    assert_response :success
  end

  test "should get edit" do
    get team_tags_edit_url
    assert_response :success
  end

  test "should get update" do
    get team_tags_update_url
    assert_response :success
  end

  test "should get new" do
    get team_tags_new_url
    assert_response :success
  end

  test "should get create" do
    get team_tags_create_url
    assert_response :success
  end
end
