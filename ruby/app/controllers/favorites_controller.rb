class FavoritesController < ApplicationController
  def update
    current_user.favorites << Haiku.find(params[:haiku_id])
    render :text => 'added'
  end
  
  def show
    @haiku = Haiku.find(params[:haiku_id])
    @users = @haiku.happy_users(:limit => 6)
    render :template => 'templates/haiku'
  end
  
  def destroy
    HaikuFavorite.destroy_all(:user_id => current_user, :haiku_id => params[:haiku_id])
    render :text => "destroyed"
  end
end