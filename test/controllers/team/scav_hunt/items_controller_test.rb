require "test_helper"

class Team::ScavHunt::ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
    @item = @tsh.items.where.not(number: nil).find(items(:one).id)
    refute_predicate @item.number, :nil?
    assert_equal [nil, @item.number], @item.for_url
  end

  test "should get index" do
    assert_authcode @team, -> { get team_scav_hunt_items_url(@tsh) } do
      assert_response :success
    end
  end

  test "should get index_mine" do
    assert_scavvie @team, -> { get team_scav_hunt_items_mine_url(@tsh) } do
      assert_response :success
    end
  end

  test "should get new" do
    assert_scavvie @team, -> { get new_team_scav_hunt_item_url(@tsh) } do
      assert_response :success
    end
  end

  test "should create with no tags" do
    assert_difference -> { Item.count } do
      assert_scavvie @team, -> { post team_scav_hunt_items_url(@tsh), params: {item: {number: 123, page_number: 456, content: "Itemium!"}} } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *Item.all.order(:created_at).last.for_url)
      end
    end
  end

  test "should create with enabled tags" do
    assert_difference -> { Item.count } do
      assert_scavvie @team, -> { post team_scav_hunt_items_url(@tsh), params: {item: {number: 124, page_number: 456, content: "Itemium!", tags: @tsh.team.team_tags.where(enabled: true).first(2).map(&:id).map(&:to_s)}} } do
        new_item = Item.all.order(:created_at).last
        assert_redirected_to team_scav_hunt_item_url(@tsh, *new_item.for_url)
        assert_equal new_item.item_tags.length, 2
      end
    end
  end

  test "should fail create with disabled tags" do
    assert_no_difference -> { Item.count } do
      assert_scavvie @team, -> { post team_scav_hunt_items_url(@tsh), params: {item: {number: 124, page_number: 456, content: "Itemium!", tags: @tsh.team.team_tags.where.not(enabled: true).map(&:id).map(&:to_s)}} } do
        assert_response :not_found
      end
    end
  end

  test "should get edit" do
    assert_scavvie @team, -> { get edit_team_scav_hunt_item_url(@tsh, *@item.for_url) } do
      assert_response :success
    end
    new_content = "Blahblah"
    assert_changes -> { @item.reload.content }, from: @item.content, to: new_content do
      assert_scavvie @team, -> { patch team_scav_hunt_item_url(@tsh, *@item.for_url), params: {item: {content: new_content}} } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
      end
    end
  end

  test "should get show" do
    assert_authcode @team, -> { get team_scav_hunt_item_url(@tsh, *@item.for_url) } do
      assert_response :success
    end
  end
end
