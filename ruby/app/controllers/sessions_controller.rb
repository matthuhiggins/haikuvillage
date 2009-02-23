class SessionsController < ApplicationController  
  def create
    author = Author.authenticate(params[:session][:username], params[:session][:password])
    session[:username] = author ? author.username : nil
    
    if session[:username]
      author.haikus.create(session[:new_haiku]) if session[:new_haiku]
      redirect_to(original_login_referrer)
    else
      flash[:notice] = "Invalid username/password combination"
      redirect_to :back
    end
  end

  def destroy
    session[:username] = nil
    flash[:notice] = "You are signed out"
    redirect_to(root_path)
  end
end