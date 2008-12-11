class ProfileController < ApplicationController
  login_filter

  def update_avatar
    if current_author.update_attributes(params[:author])
      flash[:notice] = 'Avatar saved'
    end
    redirect_to :action => 'avatar'
  end

  def password
    if request.post?
      @author = current_author
      if @author.authenticate(params[:current_password])
        if @author.update_attributes(:password => params[:password])
          flash[:notice] = "Password successfully changed"
        end
      else
        flash[:notice] = 'Wrong current password'
      end
    end
  end
end