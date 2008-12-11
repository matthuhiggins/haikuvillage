class ProfileController < ApplicationController
  login_filter

  def update_avatar
    if current_author.update_attributes(params[:author])
      flash[:notice] = 'Profile saved'
    end
    redirect_to :action => 'index'
  end

  
end