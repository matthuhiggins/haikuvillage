class ApplicationController < ActionController::Base

  before_filter :set_user
    
  def set_user
    @user = User.find_by_id(session[:user_id])
  end  
  
  def authorize
    unless @user = User.find_by_id(session[:user_id])
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "index")
    end
  end
end