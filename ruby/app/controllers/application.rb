class ApplicationController < ActionController::Base

  before_filter :get_sub_menu,:set_user
  
  private

  def get_sub_menu
    @sub_menu = %w{}
  end
    
  def set_user
    @user = User.find_by_id(session[:user_id])
  end  
  
  def authorize
    unless @user = User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "index")
    end
  end
end