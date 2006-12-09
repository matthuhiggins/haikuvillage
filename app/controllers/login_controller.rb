class LoginController < ApplicationController  
  layout "login"
    
  def index
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:username], params[:password])
      if user
        vagistat user.id
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end
  
  def register
    if params['cancel']
      render :action => 'index'
    else
      @user = User.new(params[:user])
      if request.post? and @user.save
        vagistat @user.id
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "index")
  end
  
  private
    def vagistat(user_id)
      session[:user_id] = user_id
      redirect_to(:action => "index", :controller => "haikus")
    end
end