require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module HaikuVillage
  class Application < Rails::Application
    %w(linguistics lingua).each do |lib|
      config.autoload_paths << "#{Rails.root}/vendor/#{lib}/lib"
    end

    config.active_support.deprecation = :log

    config.action_mailer.default_url_options = {
      :host => 'www.haikuvillage.com',
      :only_path => false
    }

    config.facebook = {
      app_id: '147267751983310',
      secret: 'e36a59a343c00bb05026e897e08bc8ac',
      user_class_name: 'Author'
    }

    config.encoding = 'utf-8'
    config.filter_parameters += [:password, :password_confirmation]
  end
end