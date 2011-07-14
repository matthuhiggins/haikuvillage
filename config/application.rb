require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(:default, Rails.env)

module HaikuVillage
  class Application < Rails::Application
    %w(linguistics lingua).each do |lib|
      config.autoload_paths << "#{Rails.root}/vendor/#{lib}/lib"
    end

    config.active_support.deprecation = :log

    config.action_mailer.default_url_options = {
      :host => 'haikuvillage.com',
      :only_path => false
    }

    config.assets.enabled = true
    config.filter_parameters += [:password, :password_confirmation]
  end
end

