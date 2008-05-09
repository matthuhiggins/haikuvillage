class FavoritesController < ApplicationController
  include FavoritesHelper
  
  def update
    change_favorite do |haiku|
      current_user.favorites << haiku
    end
  end
  
  def index 
    @title = 'My Favorite Haikus' 
    list_haikus(current_user.favorites)
  end
  
  def destroy
    change_favorite do |haiku|
      HaikuFavorite.destroy_all(:user_id => current_user, :haiku_id => haiku)
    end
  end
  
  private
    def change_favorite
      @haiku = Haiku.find(params[:haiku_id])
      yield(@haiku)
      
      respond_to do |f|
        f.js
      end
      
    rescue => e
      logger.debug e
      head :unprocessable_entity
    end
end