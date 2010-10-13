module Concerns::Session
  extend ActiveSupport::Concern

  included do
    before_filter :configure_facebook_author, if: lambda { fb.connected? }

    extend ActiveSupport::Memoizable
    memoize :current_author
    helper_method :current_author
  end
  
  private
    def login_and_redirect(author, remember_me = false)
      login(author, remember_me)
      create_deferred_haiku_and_redirect(author)
    end

    def login(author, remember_me = false)
      session[:author_id] = author.id
      cookies[:username] = {:value => author.username, :expires => 2.weeks.from_now}
      
      if remember_me
        author.remember_me!
        cookies[:remember_token] = {:value => author.remember_token, :expires => 2.weeks.from_now}
      end
    end

    def create_deferred_haiku_and_redirect(author)
      if session[:deferred_haiku]
        author.haikus.create(session[:deferred_haiku]) 
        session[:deferred_haiku] = nil
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

    def configure_facebook_author
      if author = (author_from_cookie || author_from_session) && author.fb_uid.nil?
        Author.migrate(author, fb.user)
      elsif fb.user.new_record?
        author = Author.find_or_create_from_graph(fb)
        login(author)
      end
    end

    def current_author
      author_from_cookie || author_from_session || author_from_facebook
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
end