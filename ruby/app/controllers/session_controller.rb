class SessionController < ApplicationController  
  def create
    user = User.authenticate(params[:username], params[:password])
    if user
      session[:user_id] = user.id
    else
      flash[:notice] = "Invalid user/password combination"
    end
    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to root_url
  end
  
  private
end