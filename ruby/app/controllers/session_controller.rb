class SessionController < ApplicationController  
  def create
    user = User.authenticate(params[:username], params[:password])
    session[:username] = user.username if user
    
    respond_to do |f|
      f.html do
        flash[:notice] = "Invalid user/password combination" unless session[:username]
        redirect_to referring_uri
      end
      f.js { head (session[:username] ? :ok : :bad_request) }
    end
  end

  def destroy
    session[:username] = nil

    respond_to do |f|
      f.html do
        flash[:notice] = "Logged out"
        redirect_to referring_uri
      end
    end
  end
  
  private
    def referring_uri
      request.env["HTTP_REFERER"] || root_url
    end
end