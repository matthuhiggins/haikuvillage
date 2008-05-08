class FavoritesController < ApplicationController
  def update
    current_user.favorites << Haiku.find(params[:haiku_id])
    render :text => 'added'
  end
  
  def show
    users = Haiku.find(params[:haiku_id]).happy_users(:limit => 6)
    render :text => "people who like this haiku: #{users.map(&:username).join(" - ")}"
  end
  
  def destroy
    HaikuFavorite.destroy_all(:user_id => current_user, :haiku_id => params[:haiku_id])
    render :text => "destroyed"
  end
end