module Application::Session
  extend ActiveSupport::Concern

  included do
    before_filter :configure_facebook_author, if: :facebook_connected?

    helper_method :current_author
    helper_method :facebook_connected?
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

    def configure_facebook_author
      if author = current_author
        Author.migrate(author, author_from_facebook) if author.fb_uid.nil?
      else
        author = Author.find_or_create_by_facebook(facebook_uid, facebook_graph)
        login(author)
      end
    end

    def facebook_graph
      @facebook_graph ||= begin
        if facebook_connected?
          Koala::Facebook::API.new(facebook_cookie["access_token"])
        end
      end
    end

    def facebook_uid
      facebook_cookie["user_id"]
    end

    def facebook_connected?
      facebook_cookie && facebook_cookie["access_token"]
    end

    def facebook_cookie
      return @facebook_cookie if instance_variable_defined?(:@facebook_cookie)
      @facebook_cookie ||= facebook_oauth.get_user_info_from_cookie(cookies)
    end

    def facebook_oauth
      @facebook_oauth ||= Koala::Facebook::OAuth.new(FacebookConfig.app_id, FacebookConfig.secret)
    end
end