require "test_helper"

class Team::ScavHunt::Item::FilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
    @item = @tsh.items.where.not(number: nil).find(items(:submitted).id)
  end

  test "should get show" do
    assert_authcode @team, -> { get team_scav_hunt_item_file_url(@tsh, *@item.for_url, @item.item_files.first.id) } do
      assert_response :success
    end
  end

  test "should create" do
    assert_difference -> { @item.reload.item_files.reload.count } do
      assert_scavvie @team, -> { post team_scav_hunt_item_files_url(@tsh, *@item.for_url), params: { item_file: {file: [file_fixture_upload('example.txt')] } } } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
      end
    end
  end

  test "should destroy" do
    assert_difference -> { @item.reload.item_files.reload.count }, -1 do
      assert_scavvie @team, -> { delete team_scav_hunt_item_file_url(@tsh, *@item.for_url, item_files(:submitted_indirect)) } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
      end
    end
  end
end
