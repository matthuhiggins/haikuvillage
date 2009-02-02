require 'concerns/twitter'

class ApplicationController < ActionController::Base
  extend ActiveSupport::Memoizable
  include TwitterController

  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  
  helper :all
        
  private
    def create_haiku_and_redirect
      # :anchor => dom_id(@haiku)
      # flash[:new_haiku_id] = @haiku.id
    end
    
    def current_author
      @current_author ||= Author.find_by_username!(session[:username]) unless session[:username].nil?
    end
    helper_method :current_author
end