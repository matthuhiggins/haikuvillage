class FavoritesController < ApplicationController
  def update
    current_user.favorites << Haiku.find(params[:haiku_id])
    flash[:notice] = 'New favorite added!'
    redirect_to haiku_url(Haiku.find(params[:haiku_id]))
  end
  
  def destroy
    HaikuFavorite.destroy_all(:user_id => current_user, :haiku_id => params[:haiku_id])
    render :text => "destroyed"
  end
end