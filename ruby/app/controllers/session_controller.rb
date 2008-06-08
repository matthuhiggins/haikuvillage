class SessionController < ApplicationController  
  def create
    author = Author.authenticate(params[:author][:username], params[:author][:password])
    session[:username] = author.username if author
    
    respond_to do |f|
      f.html do
        flash[:notice] = "Invalid username/password combination" unless session[:username]
        redirect_to referring_uri
      end
      f.js do
         head(session[:username] ? :ok : :bad_request)
       end
    end
  end

  def destroy
    session[:username] = nil

    respond_to do |f|
      f.html do
        flash[:notice] = "You are signed out"
        redirect_to referring_uri
      end
    end
  end
end