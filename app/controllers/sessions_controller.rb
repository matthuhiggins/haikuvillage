class SessionsController < ApplicationController  
  def create
    author = Author.authenticate(params[:username], params[:password])
    if author
      cookies[:username] = {:value => params[:username], :expires => 2.weeks.from_now}
      if params[:remember_me].present?
        author.remember_me!
        cookies[:remember_token] = {:value => author.remember_token, :expires => 2.weeks.from_now}
      end
      login_and_redirect(author)
    else
      flash[:notice] = "Invalid username/password combination"
      redirect_to :back
    end
  end

  def destroy
    session[:author_id] = nil
    cookies.delete :author_id
    flash[:notice] = "You are signed out"
    redirect_to(root_path)
  end
end
