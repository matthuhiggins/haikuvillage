module FavoritesHelper
  METHOD_TEXT = {
    :put    => {:image_url => "no_favorite.png",  :name => "Add favorite"},
    :delete => {:image_url => "favorite.png",     :name => "Remove favorite"}
  }
  
  def favorite_div(haiku)
    content_tag(:div, change_favorite_link(haiku), :id => dom_id(haiku, 'fav'))
  end
  
  def change_favorite_link(haiku, method = nil)
    method ||= current_user.favorites.include?(haiku) ? :delete : :put
    
    link_to_remote(:url => haiku_favorites_url(haiku), :method => method, :update => dom_id(haiku, 'fav')) do
      image_tag(METHOD_TEXT[method][:image_url], :alt => METHOD_TEXT[method][:name])
    end
  end
  
  def add_favorite_link(haiku)
    change_favorite_link(haiku, :put)
  end
  
  def remove_favorite_link(haiku)
    change_favorite_link(haiku, :delete)
  end
end