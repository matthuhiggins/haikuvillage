require 'concerns/twitter'

class ApplicationController < ActionController::Base
  extend ActiveSupport::Memoizable
  include TwitterController

  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  
  helper :all
        
  private
    def login_and_redirect(author)
      session[:username] = author.username
      if session[:new_haiku]
        author.haikus.create(session[:new_haiku]) 
        session[:new_haiku] = nil
        redirect_to(original_login_referrer)
      else
        redirect_to(original_login_request)
      end
    end
    
    def current_author
      @current_author ||= Author.find_by_username!(session[:username]) unless session[:username].nil?
    end
    helper_method :current_author
end