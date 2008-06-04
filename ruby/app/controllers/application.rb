class ApplicationController < ActionController::Base
  # Raised when a destroy action is performed on an object
  # not owned by current_author
  class UnauthorizedDestroyRequest < StandardError
  end
  
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  helper :favorites, :haikus
        
  private    
    def input_haiku(proxy, options = {})
      options.merge!(:limit => 4, :include => :author)
      @title, @right_title = options.delete(:left_title), options.delete(:right_title)
      @haikus = proxy.all(options)
      render :template => "templates/input"
    end

    def referring_uri
      params[:referrer] || request.env["HTTP_REFERER"] || root_url
    end

    def current_author
      @current_author ||= Author.first(:conditions => {:username => session[:username]}, :include => :favorites) unless session[:username].nil?
    end
    
    helper_method :referring_uri, :current_author
end