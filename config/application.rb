require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module HaikuVillage
  class Application < Rails::Application
    %w(linguistics lingua).each do |lib|
      config.load_paths.push("#{Rails.root}/vendor/#{lib}/lib")
    end

    config.action_mailer.default_url_options = {
      :host => 'www.haikuvillage.com',
      :only_path => false
    }

    config.filter_parameters += [:password]
  end
end