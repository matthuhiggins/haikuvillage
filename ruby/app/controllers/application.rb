class ApplicationController < ActionController::Base
  # Raised when a destroy action is performed on an object
  # not owned by current_user
  class UnauthorizedDestroyRequest < StandardError
  end
  
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  helper :favorites, :haikus
    
  private
    # HaikuEnv.haikus_per_page + 1 is returned so that the view knows if
    # there are more haikus on the next page.
    def list_haikus(proxy, options = {})
      offset = (current_page - 1) * HaikuEnv.haikus_per_page
      options.merge!(:offset => offset,
                     :limit => HaikuEnv.haikus_per_page + 1,
                     :include => :user)
      
      @haikus = proxy.all(options)
      render :template => "templates/listing"
    end
    
    def input_haiku(proxy, options = {})
      options.merge!(:limit => 5,
                     :joins => :user)
      @haikus = proxy.all(options)
      render :template => "templates/input"
    end
    
    # Returns the url that requested the action. This makes it easy to redirect back
    # to a url after performing a delete or update.
    def referring_uri
      request.env["HTTP_REFERER"] || root_url
    end
    
    def current_user
      @current_user ||= User.first(:conditions => {:username => session[:username]}, :include => :favorites) unless session[:username].nil?
    end
    
    def current_page
      (params[:page] || 1).to_i
    end
    
    helper_method :current_user, :current_page    
end