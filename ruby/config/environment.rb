# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/vendor/ferret/lib  )
  config.load_paths += %W( #{RAILS_ROOT}/vendor/linguistics/lib )
  config.load_paths += %W( #{RAILS_ROOT}/vendor/lingua/en )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  config.action_controller.session = {
    :session_key => '_rails_session',
    :secret      => '29bcd7b28512987fd1190aa8a4a1eab9'
  }

  config.action_controller.session_store = :active_record_store

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
end