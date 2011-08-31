require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require *Rails.groups(assets: %w(development test))

module HaikuVillage
  class Application < Rails::Application
    %w(linguistics lingua).each do |lib|
      config.autoload_paths << "#{Rails.root}/vendor/#{lib}/lib"
    end

    config.filter_parameters += [:password, :password_confirmation]

    config.assets.enabled = true
    config.active_record.identity_map = true
    config.active_support.deprecation = :stderr

    config.action_mailer.default_url_options = {
      :host => 'haikuvillage.com',
      :only_path => false
    }
  end
end

