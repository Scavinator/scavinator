require "test_helper"

class Team::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @team = teams(:one)
  end

  test "should get index" do
    assert_captain @team, -> { get team_tags_url } do
      assert_response :success
    end
  end

  test "should get edit" do
    tag = @team.team_tags.first
    assert_captain @team, -> { get edit_team_tag_url(tag) } do
      assert_response :success
    end
    new_name = "TagNameNew"
    assert_changes -> { tag.reload.name }, from: tag.name, to: new_name do
      assert_captain @team, -> { patch team_tag_url(tag), params: {team_tag: {name: new_name}} } do
        assert_redirected_to team_tags_url
      end
    end
  end

  test "should get new" do
    assert_captain @team, -> { get new_team_tag_url } do
      assert_response :success
    end
    assert_difference -> { TeamTag.count } do
      assert_captain @team, -> { post team_tags_url, params: {team_tag: {name: "TagName"}} } do
        assert_redirected_to team_tags_url
      end
    end
  end
end
