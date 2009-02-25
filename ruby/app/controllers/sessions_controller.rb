class SessionsController < ApplicationController  
  def create
    author = Author.authenticate(params[:session][:username], params[:session][:password])
    if author
      login_and_redirect(author)
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