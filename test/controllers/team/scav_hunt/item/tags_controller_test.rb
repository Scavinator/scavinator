require "test_helper"

class Team::ScavHunt::Item::TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    create_team_test_session @tsh.team, users(:one)
    @item = @tsh.items.where.not(number: nil).find(items(:one).id)
    refute_predicate @item.number, :nil?
    assert_equal [nil, @item.number], @item.for_url
  end

  test "should add tag to item" do
    @tag = @tsh.team.team_tags.find_by(enabled: true, id: team_tags(:two).id)
    assert_difference(-> { @item.item_tags.count }) do
      post team_scav_hunt_item_tags_url(@tsh, *@item.for_url), params: {item_tag: {tag_id: @tag.id}}
      assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
    end
  end

  test "should fail to add disabled tag to item" do
    @tag = @tsh.team.team_tags.find_by(enabled: false, id: team_tags(:one_disabled).id)
    assert_no_difference(-> { @item.item_tags.count }) do
      post team_scav_hunt_item_tags_url(@tsh, *@item.for_url), params: {item_tag: {tag_id: @tag.id}}
      assert_response :not_found # Maybe should be an error actually
    end
  end

  test "should remove tag from item" do
    @tag = @item.item_tags.first
    assert_difference(-> { @item.item_tags.count }, -1) do
      delete team_scav_hunt_item_tag_url(@tsh, *@item.for_url, @tag)
      assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
    end
  end

  test "should remove disabled tag from item" do
    @tag = team_tags(:one_disabled)
    @item_tag = @item.item_tags.create(team_tag_id: @tag.id)
    assert_difference(-> { @item.item_tags.count }, -1) do
      delete team_scav_hunt_item_tag_url(@tsh, *@item.for_url, @item_tag)
      assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
    end
  end
end
