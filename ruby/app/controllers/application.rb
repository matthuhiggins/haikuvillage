class ApplicationController < ActionController::Base
  # Raised when a destroy action is performed on an object
  # not owned by current_user
  class UnauthorizedDestroyRequest < StandardError
  end
  
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  
  helper :favorites
  
  HAIKUS_PER_PAGE = 5
  
  private
    def list_haikus(proxy, options = {})
      offset = ((params[:page] || 1).to_i - 1) * HAIKUS_PER_PAGE
      options.merge!(:offset => offset, :limit => HAIKUS_PER_PAGE)
      
      @haikus = proxy.all(options)
      render :template => "templates/listing"
    end
    
    def input_haiku(proxy, options = {})
      options[:limit] = HAIKUS_PER_PAGE
      @haikus = proxy.all(options)
      render :template => "templates/input"
    end
  
    def current_user
      session[:username] ? User.find_or_create_by_username(session[:username]) : nil
    end
    
    helper_method :current_user
end