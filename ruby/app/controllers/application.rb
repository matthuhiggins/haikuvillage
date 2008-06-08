class ApplicationController < ActionController::Base
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  
  helper :all
        
  private
  def referring_uri
    request.env["HTTP_REFERER"] || root_url
  end

  def current_author
    @current_author ||= Author.first(:conditions => {:username => session[:username]}, :include => :favorites) unless session[:username].nil?
  end
  
  helper_method :referring_uri, :current_author
end