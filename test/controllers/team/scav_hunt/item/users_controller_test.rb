require "test_helper"

class Team::ScavHunt::Item::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    create_team_test_session @tsh.team, users(:one)
    @item = @tsh.items.find(items(:one).id)
  end

  test "should assign user" do
    post team_scav_hunt_item_users_url(@tsh, *@item.for_url), params: {item_user: {user_id: @tsh.team.team_users.first.id}}
    assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
  end

  test "should unassign user" do
    delete team_scav_hunt_item_user_url(@tsh, *@item.for_url, @item.item_users.first)
    assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
  end
end
