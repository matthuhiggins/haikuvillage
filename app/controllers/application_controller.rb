class ApplicationController < ActionController::Base
  include Concerns::DeferredHaiku
  include Concerns::Rss
  include Concerns::Session
  include Concerns::RecordNotFound
  include Concerns::NoSubdomain

  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
end