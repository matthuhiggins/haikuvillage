class ApplicationController < ActionController::Base
  include Concerns::TwitterError
  include Concerns::Rss
  include Concerns::Session
  include HoptoadNotifier::Catcher

  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  
  helper :all
end