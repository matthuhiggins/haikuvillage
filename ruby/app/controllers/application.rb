class ApplicationController < ActionController::Base
  layout proc { |controller| controller.request.xhr? ? nil : 'haikus' }
  exempt_from_layout 'builder'
  rescue_from Twitter::AuthenticationError, :with => :invalid_twitter_credentials
  
  helper :all
        
  private
    def create_haiku_and_redirect
      @haiku = Haiku.create(params[:haiku].update(:author => current_author))
      flash[:new_haiku_id] = @haiku.id

      if params[:haiku][:conversing_with] && !params[:haiku][:conversing_with].empty?
        flash[:notice] = 'Your haiku has been added to the conversation'
        redirect_to :controller => 'haikus', :action => 'show', :id => params[:haiku][:conversing_with], :anchor => dom_id(@haiku)
      elsif params[:haiku][:conversation_id] && !params[:haiku][:conversation_id].empty?
        flash[:notice] = 'Your haiku has been added to the inspiration'
        redirect_to :controller => 'inspirations', :action => 'show', :id => params[:haiku][:conversation_id], :anchor => dom_id(@haiku)
      else
        redirect_to :controller => 'journal'
      end
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