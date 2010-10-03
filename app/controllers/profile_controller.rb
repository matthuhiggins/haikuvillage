class ProfileController < ApplicationController
  login_filter
  
  def index
    return if request.get?

    if current_author.update_attributes(params[:author])
      flash[:notice] = 'Account saved'
    end
  end

  def password
    return if request.get?
    
    if current_author.authenticate(params[:current_password])
      if current_author.update_attributes!(:password => params[:password])
        flash[:notice] = "Password successfully changed"
      end
    else
      flash[:notice] = 'Wrong current password'
    end
  end
end