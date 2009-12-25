RAILS_GEM_VERSION = '2.3.5'

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  %w(linguistics lingua).each do |lib|
    config.load_paths.push("#{Rails.root}/vendor/#{lib}/lib")
  end

  config.time_zone = 'UTC'

  config.gem 'haml',                    :version => '2.2.16'
  config.gem 'will_paginate',           :version => '2.3.11',   :lib => 'will_paginate'
  config.gem 'right_aws'
  config.gem 'shoulda',                 :version => '2.10.2',   :lib => 'shoulda'
  config.gem 'paperclip',               :version => '2.3.1.1',  :lib => 'paperclip'
  config.gem 'json',                    :version => '1.2.0'
  config.gem 'matthuhiggins-foreigner', :version => '0.3.1',    :lib => 'foreigner'

  config.action_controller.session = {
    :session_key => '_haiku_village',
    :secret => 'I bust the stupid dope moves Esteban. I got the stupid juice.'
  }

  config.action_mailer.default_url_options = {
    :host => 'www.haikuvillage.com',
    :only_path => false
  }
  
  config.after_initialize do
    ActiveSupport::JSON.backend = 'JSONGem'
  end
end