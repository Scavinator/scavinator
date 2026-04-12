require "test_helper"

class TeamControllerTest < ActionDispatch::IntegrationTest
  test "should redirect for logged out users" do
    team = teams(:one)
    get team_scav_hunt_url(team.team_scav_hunts.first, domain: team.to_domain, subdomain: false)
    assert_redirected_to team_new_session_url(domain: team.to_domain, subdomain: false)
  end

  test "should redirect for normal scavvies and show for captain" do
    team = teams(:one)
    assert_authcode team, -> { get team_url }, captain_assert: -> { assert_response :success } do
      assert_redirected_to team_scav_hunt_url(team.team_scav_hunts.first, domain: team.to_domain, subdomain: false)
    end
  end

  test "should show settings for captains" do
    assert_captain(teams(:one), -> { get url_for(controller: :team, action: :settings) }) do
      assert_response :success
    end
  end

  test "should show login page" do
    team = teams(:one)
    get team_new_session_url(team, domain: team.to_domain, subdomain: false)
    assert_response :success
  end

  test "should redirect to team page from login" do
    user = users(:one)
    team = teams(:one)
    post team_create_session_url(team, params: {email_address: user.email_address, password: 'secret'}, domain: team.to_domain, subdomain: false)
    assert_redirected_to team_url(team, domain: team.to_domain, subdomain: false)
  end

  test "should block invalid password" do
    user = users(:one)
    team = teams(:one)
    post team_create_session_url(team, params: {email_address: user.email_address, password: 'wrong_secret'}, domain: team.to_domain, subdomain: false)
    assert_redirected_to team_create_session_url
  end
end
