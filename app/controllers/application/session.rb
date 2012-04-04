module Application::Session
  extend ActiveSupport::Concern

  included do
    helper_method :current_author
  end
  
  private
    def login_and_redirect(author, remember_me = false)
      login(author, remember_me)
      redirect_to(original_login_referrer)
    end

    def login(author, remember_me = false)
      @current_author = author
      session[:author_id] = author.id
      cookies[:username] = {value: author.username, expires: 2.weeks.from_now}
      
      if remember_me
        author.remember_me!
        cookies[:remember_token] = {value: author.remember_token, expires: 2.weeks.from_now}
      end
    end

    def logout
      current_author.try(:forget_me!)
      session[:author_id] = nil
      # cookies.delete "fbsr_#{KoalaFacebook::APP_ID.to_s}"
      cookies.delete :remember_token
    end

    def current_author
      if instance_variable_defined?(:@current_author)
        @current_author
      else
        @current_author ||= (author_from_cookie || author_from_session)
      end
    end

    def author_from_cookie
      Author.find_by_remember_token(cookies[:remember_token]) if cookies[:remember_token]
    end

    def author_from_session
      Author.find(session[:author_id]) if session[:author_id]
    end
end