ENV["RAILS_ENV"] ||= "test"
require "simplecov"
SimpleCov.start "rails"
require_relative "../config/environment"
require "rails/test_help"
# ActiveRecord::Base.logger = Logger.new(STDOUT)

module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module DatabaseStatements
      # Altered from:
      # https://github.com/rails/rails/blob/b0c813bc7b61c71dd21ee3a6c6210f6d14030f71/activerecord/lib/active_record/connection_adapters/abstract/database_statements.rb#L486
      # To reverse deletion order and skip the disabling of referential integrity
      def insert_fixtures_set(fixture_set, tables_to_delete = [])
        fixture_inserts = build_fixture_statements(fixture_set)
        table_deletes = tables_to_delete.map { |table| "DELETE FROM #{quote_table_name(table)}" }.reverse
        statements = table_deletes + fixture_inserts

        transaction(requires_new: true) do
          execute_batch(statements, "Fixtures Load")
        end
      end
    end
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

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

    def assert_captain(team, request, captain_assert, scavvie_assert = -> { assert_response :not_found })
      captain_user = team.team_users.find_by(captain: true).user
      noncaptain_user = team.team_users.find_by(captain: false).user

      host! [team.prefix, Rails.configuration.scavinator_domain].join(".")
      request.call
      assert_redirected_to team_new_session_url

      create_team_test_session team, noncaptain_user
      request.call
      scavvie_assert.call

      create_team_test_session team, captain_user
      request.call
      captain_assert.call
    end

    def assert_400_error
      assert @response.response_code != 404 && @response.response_code >= 400 && @response.response_code < 500
    end
  end
end
