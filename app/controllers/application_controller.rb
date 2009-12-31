class ApplicationController < ActionController::Base
  extend ActiveSupport::Memoizable
  include Concerns::TwitterError, Concerns::Rss
  include HoptoadNotifier::Catcher

  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  
  helper :all
        
  private
    def login_and_redirect(author, remember_me = false)
      session[:author_id] = author.id

      if remember_me
        author.remember_me!
        cookies[:remember_token] = {:value => author.remember_token, :expires => 2.weeks.from_now}
      end

      if session[:new_haiku]
        author.haikus.create(session[:new_haiku]) 
        session[:new_haiku] = nil
        redirect_to(original_login_referrer)
      else
        redirect_to(original_login_request)
      end
    end
    
    def current_author
      @current_author ||= (author_from_cookie || author_from_session)
    end
    helper_method :current_author

    def author_from_cookie
      Author.find(cookies[:author_id]) unless cookies[:author_id].nil?
    end

    def author_from_session
      Author.find(session[:author_id]) unless session[:author_id].nil?
    end
end