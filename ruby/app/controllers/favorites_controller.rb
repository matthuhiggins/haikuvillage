class FavoritesController < ApplicationController
  def update
    change_favorite do |haiku|
      current_user.favorites << haiku
      flash[:notice] = 'New favorite added!'
    end
  end
  
  def destroy
    change_favorite do |haiku|
      HaikuFavorite.destroy_all(:user_id => current_user, :haiku_id => haiku)
      flash[:notice] = 'Favorite removed!'
    end
  end
  
  private
    def change_favorite
      haiku = Haiku.find(params[:haiku_id])
      yield(haiku)
        
      respond_to do |f|
        f.html { redirect_to haiku }
        f.js   { head :ok }
      end
        
    rescue => e
      head :unprocessable_entity
    end
end