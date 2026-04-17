# frozen_string_literal: true
ENV["RAILS_ENV"] ||= "test"
require "simplecov" if ENV["COVERAGE"]
require_relative "../config/environment"
require "rails/test_help"
# ActiveRecord::Base.logger = Logger.new(STDOUT)

# https://shrinerb.com/docs/testing#test-data
module TestShrine
  module_function

  def image_data
    attacher = Shrine::Attacher.new
    attacher.set(uploaded_image)
    attacher.data
  end

  def uploaded_image
    file = StringIO.new('foobarbaz.txt'.dup, File::RDWR)
    file.write "This is the contents of a test file!"

    # for performance we skip metadata extraction and assign test metadata
    uploaded_file = Shrine.upload(file, :store)
    # uploaded_file.metadata.merge!(
    #   "size"      => file.size,
    #   "mime_type" => "text/plain",
    #   "filename"  => "foobarbaz.txt",
    # )

    uploaded_file
  end
end

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

    parallelize_setup do |i|
      env_name = ActiveRecord::ConnectionHandling::DEFAULT_ENV.call
      ActiveRecord::Base.configurations.configs_for(env_name: env_name, include_hidden: true).each do |db_config|
        db_config._database = "#{db_config.database}_#{i}"
      end
      ActiveRecord::Base.establish_connection
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
      team_auths
      item_submissions
      item_files
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

    def assert_400_error
      assert @response.response_code != 404 && @response.response_code >= 400 && @response.response_code < 500, "Expected request to #{@request.url} return a 4XX error, returned a #{@response.status}"
    end
  end
end
