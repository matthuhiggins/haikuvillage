class SessionController < ApplicationController  
  def create
    user = User.authenticate(params[:user][:username], params[:user][:password])
    if user
      login_and_redirect(user.id)
    else
      flash[:notice] = "Invalid user/password combination"
    end    
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "index")
  end
  
  private
    def login_and_redirect(user_id)
      session[:user_id] = user_id
      uri = session[:original_uri]
      session[:original_uri] = nil
      redirect_to(uri || { :controller => 'haikus', :action => "index" })
    end
end