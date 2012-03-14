module Concerns::Session
  extend ActiveSupport::Concern

  included do
    before_filter :configure_facebook_author, if: :facebook_connected?

    extend ActiveSupport::Memoizable
    memoize :current_author
    helper_method :current_author
  end
  
  private
    def login_and_redirect(author, remember_me = false)
      login(author, remember_me)
      redirect_to(original_login_referrer)
    end

    def login(author, remember_me = false)
      session[:author_id] = author.id
      cookies[:username] = {:value => author.username, :expires => 2.weeks.from_now}
      
      if remember_me
        author.remember_me!
        cookies[:remember_token] = {value: author.remember_token, expires: 2.weeks.from_now}
      end
    end

    def logout
      current_author.try(:forget_me!)
      session[:author_id] = nil
      cookies.delete :remember_token
    end

    def configure_facebook_author
      if author = (author_from_cookie || author_from_session)
        Author.migrate(author, fb.user) if author.fb_uid.nil?
      elsif author_from_facebook.new_record?
        author = Author.find_or_create_from_graph(graph)
        login(author)
      end
    end

    def current_author
      author_from_cookie || author_from_session
    end

    def author_from_cookie
      Author.find_by_remember_token(cookies[:remember_token]) if cookies[:remember_token]
    end

    def author_from_session
      Author.find(session[:author_id]) if session[:author_id]
    end

    def author_from_facebook
      fb.user
    end

    def facebook_graph
      @facebook_graph ||= begin
        if facebook_connected?
          Koala::Facebook::API.new(facebook_cookie["access_token"])
        end
      end
    end

    def facebook_cookie
      return @facebook_cookie if instance_variable_defined?(:@facebook_cookie)
      @facebook_cookie ||= Koala::Facebook::OAuth.new.get_user_info_from_cookie(cookies)
    end

    def facebook_connected?
      facebook_cookie && facebook_cookie["access_token"]
    end
end