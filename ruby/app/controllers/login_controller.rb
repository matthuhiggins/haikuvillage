class LoginController < ApplicationController  
  layout "login"
    
  def index
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:username], params[:password])
      if user
        login_and_redirect(user.id)
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end
  
  def register    
    if params['cancel']
      redirect_to :action => 'index'
    else
      @user = User.new(params[:user])
      if request.post? and @user.save
        login_and_redirect(@user.id)
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "index")
  end
  
  private
    def login_and_redirect(user_id)
      session[:user_id] = user_id
      uri = session[:original_uri]
      session[:original_uri] = nil
      redirect_to(uri || { :controller => :haikus, :action => "index" })
    end
end