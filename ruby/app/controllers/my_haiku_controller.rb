class MyHaikuController < ApplicationController
  layout "haikus"
  
  set_sub_menu [
      ["My Stuff", "index"],
      ["My Favorites", "favorites"]]

  before_filter :authorize
  
  def create
    create_haiku(params[:haiku][:text]) do |haiku|
      haiku.user_id = session[:user_id]
    end
  end
  
  def favorites
    @haikus = paginated_haikus(
      :conditions => ["hf.user_id = ?", session[:user_id]],
      :joins => "join haiku_favorites hf on haikus.id = hf.haiku_id",
      :select => "haikus.*")
      
    render :action => "index"
  end
  
  def index
    @haikus = paginated_haikus(:conditions => {:user_id => session[:user_id]})
  end
  
  def add_haiku_to_favorites
    @haiku = Haiku.find(params[:id])
    @haiku.haiku_favorites.create(:user_id => session[:user_id])
  end
  
  def remove_haiku_from_favorites
    HaikuFavorite.delete_all("user_id = #{session[:user_id]} and haiku_id = #{params[:id]}")
    @haiku = Haiku.update(params[:id],  :haiku_favorites_count =>  "haiku_favorites_count - 1")
  end
end