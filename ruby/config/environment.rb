RAILS_GEM_VERSION = '2.3.0'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  %w(linguistics lingua faster_xml_simple).each do |lib|
    config.load_paths.push("#{RAILS_ROOT}/vendor/#{lib}/lib")
  end

  config.time_zone = "UTC"

  config.gem "haml",                  :version => "2.0.7"
  config.gem "libxml-ruby",           :version => '0.9.7',  :lib => "libxml"
  config.gem 'mislav-will_paginate',  :version => '2.3.6',  :lib => 'will_paginate',  :source => 'http://gems.github.com'
  config.gem 'paperclip',             :version => '2.1.2'

  config.action_controller.session = {
    :session_key => "_haiku_village",
    :secret => "I bust the stupid dope moves Esteban. I got the stupid juice."
  }
end