class SessionsController < ApplicationController  
  def create
    author = Author.authenticate(params[:username], params[:password])
    if author
      login_and_redirect(author, params[:remember_me].present?)
    else
      flash[:notice] = "Invalid username/password combination"
      redirect_to :back
    end
  end

  def destroy
    logout
    flash[:notice] = "You are signed out"
    redirect_to(root_path)
  end
end
