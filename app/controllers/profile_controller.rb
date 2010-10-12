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
    
    if current_author.update_attributes(:password => params[:password])
      redirect_to profile_path, notice: 'Password updated'
    end
  end
end