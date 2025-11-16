require "test_helper"

class Team::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
    @captain_user = @team.team_users.find_by(captain: true).user
    create_team_test_session @team, @captain_user
  end

  test "should get index" do
    get team_tags_url
    assert_response :success
  end

  test "should get edit" do
    tag = @team.team_tags.first
    get edit_team_tag_url(tag)
    assert_response :success
    new_name = "TagNameNew"
    assert_changes -> { tag.reload.name }, from: tag.name, to: new_name do
      patch team_tag_url(tag), params: {team_tag: {name: new_name}}
      assert_redirected_to team_tags_url
    end
  end

  test "should get new" do
    get new_team_tag_url
    assert_response :success
    assert_difference -> { TeamTag.count } do
      post team_tags_url, params: {team_tag: {name: "TagName"}}
      assert_redirected_to team_tags_url
    end
  end
end
