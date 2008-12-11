class ProfileController < ApplicationController
  login_filter
  
  def index
    @author = current_author
    if request.post?
      if @author.update_attributes(params[:author])
        session[:username] = @author.username
        flash[:notice] = 'Account saved'
      end
    end
  end

  def update_avatar
    if current_author.update_attributes(params[:author])
      flash[:notice] = 'Avatar saved'
    end
    redirect_to :action => 'avatar'
  end

  def password
    if request.post?
      if current_author.authenticate(params[:current_password])
        if current_author.update_attributes(:password => params[:password])
          flash[:notice] = "Password successfully changed"
        end
      else
        flash[:notice] = 'Wrong current password'
      end
    end
  end
end