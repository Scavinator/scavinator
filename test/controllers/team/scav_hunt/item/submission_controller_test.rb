require "test_helper"

class Team::ScavHunt::Item::SubmissionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tsh = team_scav_hunts(:one)
    @team = @tsh.team
    @item = @tsh.items.where.not(number: nil).find(items(:one).id)
  end

  test "should get show" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    assert_authcode team, -> { get team_scav_hunt_item_url(tsh, *item.for_url) } do
      assert_response :success
    end
  end

  test "should get new" do
    assert_scavvie @team, -> { get new_team_scav_hunt_item_submission_url(@tsh, *@item.for_url) } do
      assert_response :success
    end
  end

  test "should get edit" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    assert_scavvie team, -> { get edit_team_scav_hunt_item_submission_url(tsh, *item.for_url) } do
      assert_response :success
    end
  end

  test "should patch edit" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    new_message = "Bleep bloop"
    assert_changes -> { item.item_submission.reload.instructions }, to: new_message do
      assert_scavvie team, -> { patch team_scav_hunt_item_submission_url(tsh, *item.for_url), params: { item_submission: { instructions: new_message } } } do
        assert_redirected_to team_scav_hunt_item_url(tsh, *item.for_url)
      end
    end
  end

  test "should get delete" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    assert_changes -> { item.reload.item_submission&.instructions }, from: item.item_submission.instructions, to: nil do
      assert_scavvie team, -> { delete team_scav_hunt_item_submission_url(tsh, *item.for_url) } do
        assert_redirected_to team_scav_hunt_item_url(tsh, *item.for_url)
      end
    end
  end

  test "should get create" do
    new_message = "Blahblah"
    assert_changes -> { @item.reload.item_submission&.instructions }, from: nil, to: new_message do
      assert_scavvie @team, -> { post team_scav_hunt_item_submission_url(@tsh, *@item.for_url), params: {item_submission: {instructions:  new_message} } } do
        assert_redirected_to team_scav_hunt_item_url(@tsh, *@item.for_url)
      end
    end
  end

  test "should block attaching invalid files" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    assert_no_changes -> { item.item_submission.reload.item_files.count } do
      assert_scavvie team, -> { post team_scav_hunt_item_submission_file_attach_url(tsh, *item.for_url), params: { item_file: { import_files: [item_files(:submitted_direct).id] } } } do
        assert_redirected_to team_scav_hunt_item_url(tsh, *item.for_url)
      end
    end
    assert_no_changes -> { item.item_submission.reload.item_files.count } do
      assert_scavvie team, -> { post team_scav_hunt_item_submission_file_attach_url(tsh, *item.for_url), params: { item_file: { import_files: [item_files(:one).id] } } } do
        assert_redirected_to team_scav_hunt_item_url(tsh, *item.for_url)
      end
    end
    assert_no_changes -> { item.item_submission.reload.item_files.count } do
      assert_scavvie team, -> { delete team_scav_hunt_item_submission_file_detach_url(tsh, *item.for_url, item_files(:submitted_indirect).id) } do
        assert_response :not_found
      end
    end
  end

  test "should attach drafted files" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    assert_difference -> { item.item_submission.reload.item_files.count } do
      assert_scavvie team, -> { post team_scav_hunt_item_submission_file_attach_url(tsh, *item.for_url), params: { item_file: { import_files: [item_files(:submitted_indirect).id] } } } do
        assert_redirected_to team_scav_hunt_item_url(tsh, *item.for_url)
      end
    end
  end

  test "should detach files" do
    item = items(:submitted)
    tsh = item.team_scav_hunt
    team = tsh.team
    assert_difference -> { item.item_submission.reload.item_files.count }, -1 do
      assert_scavvie team, -> { delete team_scav_hunt_item_submission_file_detach_url(tsh, *item.for_url, item_files(:submitted_direct).id) } do
        assert_redirected_to team_scav_hunt_item_url(tsh, *item.for_url)
      end
    end
  end
end
