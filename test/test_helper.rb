ENV["RAILS_ENV"] ||= "test"
require "simplecov" if ENV["COVERAGE"]
require_relative "../config/environment"
require "rails/test_help"
# ActiveRecord::Base.logger = Logger.new(STDOUT)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # https://railstemplates.org/simplecov-rails/
    if ENV["COVERAGE"]
      SimpleCov.start "rails"
      parallelize_setup do |worker|
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end

      parallelize_teardown do |worker|
        SimpleCov.result
      end
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in order (default is alphabetical)
    # find test/fixtures/ -maxdepth 1 -mindepth 1 -name "*.yml" | sed 's/.*\/\(.*\)\.yml$/\1/'
    fixture_names = %w[
      teams
      users
      scav_hunts
      team_scav_hunts
      list_categories
      team_users
      pages
      items
      item_users
      team_tags
      page_captains
      item_tags
      team_roles
      team_role_members
    ]
    self.fixture_table_names = fixture_names
    setup_fixture_accessors fixture_names


    # Add more helper methods to be used by all tests here...
    def logger
      @logger ||= Logger.new(STDOUT)
      @logger
    end

    def create_test_session(user)
      post url_for(controller: :sessions, action: :create, domain: Rails.configuration.scavinator_domain, subdomain: false), params: {email_address: user.email_address, password: 'secret'}
      assert_redirected_to root_dash_url
    end

    def create_team_test_session(team, user)
      post team_new_session_url(domain: team&.to_domain, subdomain: false), params: {email_address: user.email_address, password: 'secret'}
      assert_redirected_to team_url
    end

    def assert_scavvie(team, request, scavvie_assert: nil, public_assert: -> { assert_redirected_to team_new_session_url, "Expected public request to #{@request.url} to hit the login wall but returned a #{@response.status}" }, &block)
      scavvie_assert ||= block
      raise ArgumentError "Missing scavvie assertion" if scavvie_assert.nil?

      noncaptain_user = team.team_users.find_by(captain: false).user

      reset!

      # Test that public access is login-walled
      host! [team.prefix, Rails.configuration.scavinator_domain].join(".")
      # This wrapper prevents the assert_no_queries from catching lazy queries from evaluating ActiveRecord
      # objects in the url_for call
      # In real world use, it could query once if a session cookie is present
      NoQueriesRequestWrap.instance_exec { request.call }
      public_assert.call

      create_team_test_session team, noncaptain_user
      request.call
      scavvie_assert.call
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

    def assert_captain(team, request, captain_assert: nil, scavvie_assert: -> { assert_response :not_found, "Expected scavvie request to return a 404 returned a #{@response.status}" }, &block)
      captain_assert ||= block
      raise ArgumentError "Missing captain assertion" if captain_assert.nil?

      captain_user = team.team_users.find_by(captain: true).user
      # noncaptain_user = team.team_users.find_by(captain: false).user

      assert_scavvie(team, -> {
          # The double negative is required because `assert_queries_match` requires
          # at least one query, and it's possible that there will be zero
          assert_no_queries_match(InverseRegex.new(/^SELECT /i)) do
            request.call
          end
        },
        scavvie_assert: scavvie_assert)

      reset!

      # # Test that public access is login-walled
      # host! [team.prefix, Rails.configuration.scavinator_domain].join(".")
      # # This wrapper prevents the assert_no_queries from catching lazy queries from evaluating ActiveRecord
      # # objects in the url_for call
      # # In real world use, it could query once if a session cookie is present
      # NoQueriesRequestWrap.instance_exec { request.call }
      # assert_redirected_to team_new_session_url

      # create_team_test_session team, noncaptain_user
      # assert_queries_match(/^SELECT /i) do
      #   request.call
      # end
      # scavvie_assert.call

      create_team_test_session team, captain_user
      request.call
      captain_assert.call
    end

    def assert_400_error
      assert @response.response_code != 404 && @response.response_code >= 400 && @response.response_code < 500, "Expected request to #{@request.url} return a 4XX error, returned a #{@response.status}"
    end
  end
end
