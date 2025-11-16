require "test_helper"

class TeamControllerTest < ActionDispatch::IntegrationTest
  test "should redirect for logged out users" do
    team = teams(:one)
    get team_scav_hunt_url(team, domain: team.to_domain, subdomain: false)
    assert_redirected_to team_new_session_url(domain: team.to_domain, subdomain: false)
  end

  test "should redirect for normal scavvies" do
    user = users(:one)
    create_test_session user
    team = user.teams.first
    get url_for(controller: :team, action: :show, domain: team.to_domain)
    assert_redirected_to team_scav_hunt_url(team.team_scav_hunts.first, domain: team.to_domain, subdomain: false)
  end

  test "should show dashboard for captains" do
    user = users(:one_captain)
    create_test_session user
    team = user.teams.first
    get url_for(controller: :team, action: :show, domain: team.to_domain)
    assert_response :success
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
end
