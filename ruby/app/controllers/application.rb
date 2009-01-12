class ApplicationController < ActionController::Base
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  rescue_from Twitter::AuthenticationError, :with => :invalid_twitter_credentials
  
  helper :all
        
  private
    def create_haiku_and_redirect
      # :anchor => dom_id(@haiku)
      # flash[:new_haiku_id] = @haiku.id
    end
    
    def invalid_twitter_credentials
      flash[:notice] = "Your Twitter credentials are out of date"
      redirect_to :controller => "profile", :action => "twitter"
    end
  
    def referring_uri
      request.env["HTTP_REFERER"] || root_url
    end

    def current_author
      @current_author ||= Author.first(:conditions => {:username => session[:username]}, :include => :favorites) unless session[:username].nil?
    end
  
  helper_method :current_author
end