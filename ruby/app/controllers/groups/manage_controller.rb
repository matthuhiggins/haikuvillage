class ManageController < ApplicationController
  def index
    
  end
  
  def update_avatar
    if current_group.update_attributes(params[:group])
      flash[:notice] = 'Avatar saved'
    end
    redirect_to :action => 'avatar'
  end
end