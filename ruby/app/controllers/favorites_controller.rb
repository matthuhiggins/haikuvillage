class FavoritesController < ApplicationController
  include FavoritesHelper
  
  login_filter
  
  def update
    change_favorite do |haiku|
      current_author.favorites << haiku
    end
  end
  
  def index 
    list_haikus(current_author, :favorites, :title => "Your Favorite Haikus", :cached_total => :favorites_count)
  end
  
  def destroy
    change_favorite do |haiku|
      HaikuFavorite.destroy_all(:author_id => current_author, :haiku_id => haiku)
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