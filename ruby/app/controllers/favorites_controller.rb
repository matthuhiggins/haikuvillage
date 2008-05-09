class FavoritesController < ApplicationController  
  def update
    change_favorite do |haiku|
      current_user.favorites << haiku
      respond_to do |f|
        f.html { 
          flash[:notice] = 'New favorite added!' 
          redirect_to haiku
        }
        f.js { render :text => ApplicationHelper.remove_favorite_link(haiku) }
      end
    end
  end
  
  def index 
    @title = 'My Favorite Haikus' 
    list_haikus(current_user.favorites)
  end
  
  def destroy
    change_favorite do |haiku|
      HaikuFavorite.destroy_all(:user_id => current_user, :haiku_id => haiku)
      respond_to do |f|
        f.html { 
          flash[:notice] = 'Favorite removed!'
          redirect_to haiku
        }
        f.js { render :text => ApplicationHelper.add_favorite_link(haiku) }
      end
    end
  end
  
  private
    def change_favorite
      haiku = Haiku.find(params[:haiku_id])
      yield(haiku)
    rescue => e
      logger.debug e
      head :unprocessable_entity
    end
    
    def add_favorite_link(haiku)
      link_to_remote "Add favorite", 
        :url => haiku_favorites_url(haiku), 
        :href => haiku_favorites_url(haiku), 
        :method => :put, 
        :update => haiku.unique_id("fav"), 
        :html => {:id => haiku.unique_id("fav")}
    end
    helper_method :add_favorite_link

    def remove_favorite_link(haiku)
      link_to_remote "Remove favorite", 
        :url => haiku_favorites_url(haiku), 
        :href => haiku_favorites_url(haiku), 
        :method => :delete, 
        :update => haiku.unique_id("fav"), 
        :html => {:id => haiku.unique_id("fav")}
    end
    helper_method :remove_favorite_link
end