class ApplicationController < ActionController::Base
  def authorize
    unless User.find_by_id(session[:user_id])
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "index")
    end
  end
end