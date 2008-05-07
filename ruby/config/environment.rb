# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  %w(linguistics lingua faster_xml_simple).each do |lib|
    config.load_paths.push("#{RAILS_ROOT}/vendor/#{lib}/lib")
  end
  
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  config.action_controller.session = {
    :session_key => "_haiku_village",
    :secret => "I bust the stupid dope moves Esteban. I got the stupid juice."
  }

  config.active_record.default_timezone = :utc
end