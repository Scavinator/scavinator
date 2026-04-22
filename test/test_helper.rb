# frozen_string_literal: true
ENV["RAILS_ENV"] ||= "test"
require "simplecov" if ENV["COVERAGE"]
require_relative "../config/environment"
require "rails/test_help"
require "test_helpers/role_assertions"
require "test_helpers/form_assertions"
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

module ActiveRecord
  class FixtureSet
    class TableRow # :nodoc:
      def generate_primary_key
        pk = model_metadata.primary_key_name

        unless column_defined?(pk)
          # Use model class as the ID in test cases to make sure we get FK errors if we pass the wrong ID
          # type to a certain class
          @row[pk] = ActiveRecord::FixtureSet.identify("#{model_class}-#{@label}", model_metadata.column_type(pk))
        end
      end

      private
        def resolve_sti_reflections
          # If STI is used, find the correct subclass for association reflection
          reflection_class._reflections.each_value do |association|
            case association.macro
            when :belongs_to
              # Do not replace association name with association foreign key if they are named the same
              fk_name = association.join_foreign_key

              if association.name.to_s != fk_name && value = @row.delete(association.name.to_s)
                if association.polymorphic?
                  if value.sub!(/\s*\(([^)]*)\)\s*$/, "")
                    # support polymorphic belongs_to as "label (Type)"
                    @row[association.join_foreign_type] = $1
                  end
                elsif association.join_primary_key != association.klass.primary_key
                  raise PrimaryKeyError.new(@label, association, value)
                end

                if fk_name.is_a?(Array)
                  composite_key = ActiveRecord::FixtureSet.composite_identify(value, fk_name)
                  composite_key.each do |column, value|
                    next if column_defined?(column)

                    @row[column] = value
                  end
                else
                  fk_type = reflection_class.type_for_attribute(fk_name).type
                  # Logger.new(STDOUT).info "#{reflection_class} #{fk_name} #{association.class_name} #{association.inspect}"
                  @row[fk_name] = ActiveRecord::FixtureSet.identify("#{association.class_name}-#{value}", fk_type)
                end
              end
            when :has_many
              if association.options[:through]
                add_join_records(HasManyThroughProxy.new(association))
              end
            end
          end
        end
    end
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
      page_captains
      team_roles
      team_tags
      item_tags
      team_role_members
      team_auths
      item_submissions
      item_files
      item_events
    ]
    self.fixture_table_names = fixture_names
    setup_fixture_accessors fixture_names
    # fixtures :all

    # Add more helper methods to be used by all tests here...
    def logger
      @logger ||= Logger.new(STDOUT)
      @logger
    end

    def create_test_session(user)
      post url_for(controller: :sessions, action: :create, domain: Rails.configuration.scavinator_domain, subdomain: false), params: {email_address: user.email_address, password: 'secret'}
      assert_redirected_to root_root_url
    end

    def create_team_test_session(team, user)
      post team_new_session_url(domain: team&.to_domain, subdomain: false), params: {email_address: user.email_address, password: 'secret'}
      assert_redirected_to team_url
    end

    def assert_400_error
      assert @response.response_code != 404 && @response.response_code >= 400 && @response.response_code < 500, "Expected request to #{@request.url} return a 4XX error, returned a #{@response.status}"
    end
  end
end

class ActionDispatch::IntegrationTest
  include RoleAssertions
  include FormAssertions
end
