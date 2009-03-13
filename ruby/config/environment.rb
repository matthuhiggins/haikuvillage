RAILS_GEM_VERSION = '2.3.1'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  %w(linguistics lingua faster_xml_simple).each do |lib|
    config.load_paths.push("#{RAILS_ROOT}/vendor/#{lib}/lib")
  end

  config.time_zone = "UTC"

  config.gem "haml",                  :version => "2.0.9"
  config.gem "libxml-ruby",           :version => '1.1.1',  :lib => 'libxml'
  config.gem 'mislav-will_paginate',  :version => '2.3.7',  :lib => 'will_paginate',  :source => 'http://gems.github.com'
  config.gem 'right_aws'
  config.gem 'thoughtbot-shoulda',    :version => '2.10.1', :lib => 'shoulda',        :source => 'http://gems.github.com'
  config.gem 'thoughtbot-paperclip',  :version => '2.2.6',  :lib => 'paperclip',      :source => 'http://gems.github.com'

  config.action_controller.session = {
    :session_key => "_haiku_village",
    :secret => "I bust the stupid dope moves Esteban. I got the stupid juice."
  }

  config.action_mailer.default_url_options = {
    :host => "www.haikuvillage.com",
    :only_path => false
  }
end