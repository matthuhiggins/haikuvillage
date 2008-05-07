class ApplicationController < ActionController::Base
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
      
  private
    def current_user
      session[:username] ? User.find_or_create_by_username(session[:username]) : nil
    end
    helper_method :current_user
end