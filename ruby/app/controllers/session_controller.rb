class SessionController < ApplicationController  
  def create
    author = Author.authenticate(params[:session][:username], params[:session][:password])
    session[:username] = author ? author.username : nil
    
    if session[:username]
      if params[:haiku]
        create_haiku_and_redirect
      else
        redirect_to :back
      end
    else
      flash[:notice] = "Invalid username/password combination"
      redirect_to :back
    end
  end

  def destroy
    session[:username] = nil
    flash[:notice] = "You are signed out"
    redirect_to referring_uri
  end
end