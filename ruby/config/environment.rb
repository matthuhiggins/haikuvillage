# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.load_paths += %W( #{RAILS_ROOT}/vendor/linguistics/lib )
  config.load_paths += %W( #{RAILS_ROOT}/vendor/lingua/en )

  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  config.active_record.default_timezone = :utc
end