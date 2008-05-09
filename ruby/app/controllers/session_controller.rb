class SessionController < ApplicationController  
  def create
    user = User.authenticate(params[:username], params[:password])
    session[:username] = user.username if user
    
    respond_to do |f|
      f.html do
        if session[:username]
          redirect_to(request.env["HTTP_REFERER"] || root_url)
        else
          flash[:notice] = "Invalid user/password combination"
        end
      end
      f.js { head (session[:username] ? :ok : :bad_request) }
    end
  end

  def destroy
    session[:username] = nil

    respond_to do |f|
      f.html do
        flash[:notice] = "Logged out"
        redirect_to root_url
      end
    end
  end
  
  private
end