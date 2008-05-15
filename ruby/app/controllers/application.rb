class ApplicationController < ActionController::Base
  # Raised when a destroy action is performed on an object
  # not owned by current_user
  class UnauthorizedDestroyRequest < StandardError
  end
  
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  helper :favorites, :haikus
  
  before_filter :basic_auth
      
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
      options.merge!(:limit => 4,
                     :include => :user)
      @haikus = proxy.all(options)
      render :template => "templates/input"
    end
    
    def referring_uri
      params[:referrer] || request.env["HTTP_REFERER"] || root_url
    end
    
    def current_user
      @current_user ||= User.first(:conditions => {:username => session[:username]}, :include => :favorites) unless session[:username].nil?
    end
    
    def current_page
      (params[:page] || 1).to_i
    end
    
    helper_method :referring_uri, :current_user, :current_page
    
    def basic_auth
      return if local_request?
      
      authenticate_or_request_with_http_basic do |user_name, password| 
        user_name == 'haiku' && password == '575'
      end
    end
end