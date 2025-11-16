require "test_helper"

class Team::ScavHunt::ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    create_team_test_session @tsh.team, users(:one)
    @item = @tsh.items.where.not(number: nil).find(items(:one).id)
    refute_predicate @item.number, :nil?
    assert_equal [nil, @item.number], @item.for_url
  end

  test "should get index" do
    get team_scav_hunt_items_url(@tsh)
    assert_response :success
  end

  test "should get index_mine" do
    get team_scav_hunt_items_mine_url(@tsh)
    assert_response :success
  end

  test "should get new" do
    get new_team_scav_hunt_item_url(@tsh)
    assert_response :success
    assert_difference -> { Item.count } do
      post team_scav_hunt_items_url(@tsh), params: {item: {number: 123, page_number: 456, content: "Itemium!"}}
      assert_redirected_to team_scav_hunt_item_url(@tsh, *Item.all.order(:created_at).last.for_url)
    end
  end

  test "should get edit" do
    get edit_team_scav_hunt_item_url(@tsh, *@item.for_url)
    assert_response :success
    new_content = "Blahblah"
    assert_changes -> { @item.reload.content }, from: @item.content, to: new_content do
      patch team_scav_hunt_item_url(@tsh, *@item.for_url), params: {item: {content: new_content}}
      assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
    end
  end

  test "should get show" do
    get team_scav_hunt_item_url(@tsh, *@item.for_url)
    assert_response :success
  end
end
