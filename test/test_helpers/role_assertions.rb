module RoleAssertions
  def assert_authcode(team, request, authcode_assert: nil, public_assert: -> { assert_redirected_to team_new_session_url, "Expected public request to #{@request.url} to hit the login wall but returned a #{@response.status}" }, captain_assert: nil, &block)
    authcode_assert ||= block || -> { assert_response :success }
    raise ArgumentError, "Missing authcode assertion" if authcode_assert.nil?

    reset!

    # Test that public access is login-walled
    host! [team.prefix, Rails.configuration.scavinator_domain].join(".")
    # This wrapper prevents the assert_no_queries from catching lazy queries from evaluating ActiveRecord
    # objects in the url_for call
    # In real world use, it could query once if a session cookie is present
    NoQueriesRequestWrap.instance_exec { request.call }
    public_assert.call

    get team_url, params: {authcode: team.team_auths.first.key}
    request.call
    authcode_assert.call

    # If it's accessible with authcode, it should also be accessible to scavvies
    assert_scavvie(team, request, scavvie_assert: authcode_assert, public_assert: public_assert, captain_assert: captain_assert, allow_authcode: true)
  end

  def assert_scavvie(team, request, scavvie_assert: nil, public_assert: -> { assert_redirected_to team_new_session_url, "Expected public request to #{@request.url} to hit the login wall but returned a #{@response.status}" }, captain_assert: nil, allow_authcode: false, scavvie_user: nil, &block)
    scavvie_assert ||= block
    raise ArgumentError, "Missing scavvie assertion" if scavvie_assert.nil?

    noncaptain_user = scavvie_user || team.team_users.find_by(captain: false).user

    reset!

    # Test that public access is login-walled
    host! [team.prefix, Rails.configuration.scavinator_domain].join(".")
    # This wrapper prevents the assert_no_queries from catching lazy queries from evaluating ActiveRecord
    # objects in the url_for call
    # In real world use, it could query once if a session cookie is present
    NoQueriesRequestWrap.instance_exec { request.call }
    public_assert.call

    if !allow_authcode
      get team_url, params: {authcode: team.team_auths.first.key}
      NoQueriesRequestWrap.instance_exec { request.call }
      public_assert.call
    end

    reset!
    host! [team.prefix, Rails.configuration.scavinator_domain].join(".")

    create_team_test_session team, noncaptain_user
    request.call
    scavvie_assert.call

    if captain_assert
      captain_user = team.team_users.find_by(captain: true).user
      create_team_test_session team, captain_user
      request.call
      captain_assert.call
    end
  end

  module NoQueriesRequestWrap
    %i[get post put patch delete].each do |method|
      define_method(method) do |path, **args|
        assert_no_queries do
          process(method, path, **args)
        end
      end
    end
  end

  class InverseRegex
    def initialize(regex)
      @regex = regex
    end

    def ===(v)
      !(@regex === v)
    end
  end

  def assert_captain(team, request, captain_assert: nil, public_assert: -> { assert_response :not_found, "Expected public request to return a 404 returned a #{@response.status}" }, scavvie_assert: nil, captain_user: nil, &block)
    captain_assert ||= block
    scavvie_assert ||= public_assert
    raise ArgumentError, "Missing captain assertion" if captain_assert.nil?

    captain_user ||= team.team_users.find_by(captain: true).user

    # The assert_scavvie implicitly also asserts that public access is blocked
    # if that is skipped, we need to assert that here instead
    if !scavvie_assert.nil?
      assert_scavvie(team, -> {
          # The double negative is required because `assert_queries_match` requires
          # at least one query, and it's possible that there will be zero
          assert_no_queries_match(InverseRegex.new(/^SELECT /i)) do
            request.call
          end
        },
        scavvie_assert: scavvie_assert,
        public_assert: public_assert
      )
    end

    reset!
    host! [team.prefix, Rails.configuration.scavinator_domain].join(".")

    create_team_test_session team, captain_user
    request.call
    captain_assert.call
  end
end
