class FavoritesController < ApplicationController
  login_filter
  
  def index
    @haikus = current_author.favorite_haikus.recent.page(params[:page]).per(10)
    # :total_entries => current_author.favorites_count
  end
  
  def update
    change_favorite { |haiku| current_author.favorite_haikus << haiku }
  end
  
  def destroy
    change_favorite { |haiku| Favorite.destroy_all(author_id: current_author, haiku_id: haiku) }
  end
  
  private
    def change_favorite
      @haiku = Haiku.find(params[:id])
      yield(@haiku)
    rescue => e
      logger.debug e
      head :unprocessable_entity
    end
end