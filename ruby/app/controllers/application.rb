class ApplicationController < ActionController::Base
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
      
  private
    def current_user
      User.find(session[:user_id])
    end
    helper_method :current_user
end