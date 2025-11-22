require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! Rails.configuration.scavinator_domain
    @user = users(:one)
  end

  test "should get new" do
    get new_session_url
    assert_response :success
  end

  test "should block invalid password" do
    post session_url(params: {email_address: @user.email_address, password: 'wrong_secret'})
    assert_redirected_to new_session_url
  end

  test "should allow login" do
    post session_url(params: {email_address: @user.email_address, password: 'secret'})
    assert_redirected_to root_dash_url
  end

  test "should get destroy" do
    post session_url(params: {email_address: @user.email_address, password: 'secret'})
    assert_redirected_to root_dash_url
    get root_dash_url
    assert_response :success
    delete session_url
    assert_redirected_to new_session_url
    get root_dash_url
    assert_redirected_to new_session_url
  end
end
