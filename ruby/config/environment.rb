# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  %w(linguistics lingua faster_xml_simple).each do |lib|
    config.load_paths.push("#{RAILS_ROOT}/vendor/#{lib}/lib")
  end
    
  config.action_controller.session = {
    :session_key => "_haiku_village",
    :secret => "I bust the stupid dope moves Esteban. I got the stupid juice."
  }
  
  config.action_controller.cache_store = :mem_cache_store, "localhost"

  config.time_zone = "Pacific Time (US & Canada)"
  config.active_record.default_timezone = :utc
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :haiku => "%b %d, %Y"
)