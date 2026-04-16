require "shrine"

# https://github.com/rails/rails/blob/450e18fe3e7da7fe9ab0162d910f93cb68f486ab/activestorage/lib/active_storage/engine.rb#L176-L182
config_file = Rails.root.join("config/storage/#{Rails.env}.yml")
config_file = Rails.root.join("config/storage.yml") unless config_file.exist?
raise("Couldn't find Shrine configuration in #{config_file}") unless config_file.exist?
full_conf = ActiveSupport::ConfigurationFile.parse(config_file)
conf = full_conf[Rails.configuration.shrine_service.to_s]

# https://github.com/erikdahlstrand/shrine-rails-example/blob/5d45bec79c5e2d07339ae207a85b9853a7849c3b/config/initializers/shrine.rb#L4-L23
case conf['service']
when 'S3'
  require "shrine/storage/s3"

  conf.delete('service')
  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **conf.symbolize_keys),
    store: Shrine::Storage::S3.new(**conf.symbolize_keys),
  }
when 'Disk'
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new(conf['root'] || "public", prefix: "uploads/cache"),
    store: Shrine::Storage::FileSystem.new(conf['root'] || "public", prefix: "uploads"),
  }
when 'Memory'
  require "shrine/storage/memory"

  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }
else
  raise "No storage backend configured"
end

Shrine.plugin :activerecord           # loads Active Record integration
Shrine.plugin :rack_response
