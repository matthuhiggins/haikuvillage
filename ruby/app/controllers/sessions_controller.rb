class SessionsController < ApplicationController  
  def create
    author = Author.authenticate(params[:username], params[:password])
    if author
      cookies[:username] = {:value => params[:username], :expires => 2.weeks.from_now}
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