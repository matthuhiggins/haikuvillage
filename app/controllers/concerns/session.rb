module Concerns::Session
  def self.included(controller)
    controller.helper_method :current_author
  end
  
  private
    def login_and_redirect(author, remember_me = false)
      session[:author_id] = author.id
      
      if params[:remember_me].present?
        author.remember_me!
        cookies[:remember_token] = {:value => author.remember_token, :expires => 2.weeks.from_now}
      end
      
      cookies[:username] = {:value => author.username, :expires => 2.weeks.from_now}

      if session[:new_haiku]
        author.haikus.create(session[:new_haiku]) 
        session[:new_haiku] = nil
        redirect_to(original_login_referrer)
      else
        redirect_to(original_login_request)
      end
    end
    
    def logout
      current_author.try(:forget_me!)
      session[:author_id] = nil
      cookies.delete :remember_token
    end
    
    def current_author
      @current_author ||= (author_from_cookie || author_from_session)
    end

    def author_from_cookie
      Author.find_by_remember_token(cookies[:remember_token]) unless cookies[:remember_token].nil?
    end

    def author_from_session
      Author.find(session[:author_id]) unless session[:author_id].nil?
    end
end