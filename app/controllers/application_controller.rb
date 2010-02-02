class ApplicationController < ActionController::Base
  include Concerns::TwitterError
  include Concerns::Rss
  include Concerns::Session

  filter_parameter_logging :password, :password_confirmation
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  
  helper :all
end