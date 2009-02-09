module FavoritesHelper
  METHOD_TEXT = {
    :put    => {:image_url => "icons/no_favorite.png",  :name => "Add favorite"},
    :delete => {:image_url => "icons/favorite.png",     :name => "Remove favorite"}
  }
  
  def favorite_star(haiku)
    content_tag(:div, change_favorite_link(haiku), :id => dom_id(haiku, 'change_fav'), :class => "action")
  end
    
  def add_favorite_link(haiku)
    favorite_link(haiku, :put)
  end
  
  def remove_favorite_link(haiku)
    favorite_link(haiku, :delete)
  end
  
  private
    def change_favorite_link(haiku)
      favorite_link(haiku, current_author.favorites.exists?(:haiku_id => haiku) ? :delete : :put)
    end
  
    def favorite_link(haiku, method)
      link_to_remote(favorite_image_tag(method),
          :url => favorite_url(haiku),
          :method => method,
          :update => dom_id(haiku, 'change_fav'))
    end
  
    def favorite_image_tag(method)
      image_tag(METHOD_TEXT[method][:image_url], :alt => METHOD_TEXT[method][:name])
    end
end