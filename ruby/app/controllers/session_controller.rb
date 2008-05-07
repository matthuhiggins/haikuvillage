class SessionController < ApplicationController  
  def create
    user = User.authenticate(params[:username], params[:password])
    if user
      session[:username] = user.username
    else
      flash[:notice] = "Invalid user/password combination"
    end
    redirect_to root_url
  end

  def destroy
    session[:username] = nil
    flash[:notice] = "Logged out"
    redirect_to root_url
  end
  
  private
end