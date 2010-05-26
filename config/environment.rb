RAILS_GEM_VERSION = '2.3.8'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  %w(linguistics lingua).each do |lib|
    config.load_paths.push("#{Rails.root}/vendor/#{lib}/lib")
  end

  config.time_zone = 'UTC'

  config.gem 'haml',                    :version => '3.0.6'
  config.gem 'will_paginate',           :version => '2.3.12'
  config.gem 'gravtastic',              :version => '2.2.0'
  config.gem 'matthuhiggins-foreigner', :version => '0.6.0',    :lib => 'foreigner'

  config.action_controller.session = {
    :session_key => '_haiku_village',
    :secret => 'I bust the stupid dope moves Esteban. I got the stupid juice.'
  }

  config.action_mailer.default_url_options = {
    :host => 'www.haikuvillage.com',
    :only_path => false
  }
end