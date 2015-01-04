class ApplicationController < ActionController::Base
  include Application::DeferredHaiku
  include Application::LoginFilter
  include Application::RecordNotFound
  include Application::Rss
  include Application::Session
  include Application::FacebookContext

  layout proc { |controller| controller.request.xhr? ? nil : 'application' }
end
