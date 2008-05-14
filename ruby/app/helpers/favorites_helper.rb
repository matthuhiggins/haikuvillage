module FavoritesHelper
  METHOD_TEXT = {
    :put    => {:image_url => "no_favorite.png",  :name => "Add favorite"},
    :delete => {:image_url => "favorite.png",     :name => "Remove favorite"}
  }
  
  def favorite_span(haiku)
    content_tag(:span, change_favorite_link(haiku), :id => dom_id(haiku, 'change_fav'))
  end
    
  def add_favorite_link(haiku)
    favorite_link(haiku, :put)
  end
  
  def remove_favorite_link(haiku)
    favorite_link(haiku, :delete)
  end
  
  private
  
  def change_favorite_link(haiku)
    favorite_link(haiku, current_user.favorites.include?(haiku) ? :delete : :put)
  end
  
  def favorite_link(haiku, method)
    link_to_remote(favorite_image_tag(method),
        :url => haiku_favorites_url(haiku),
        :method => method,
        :update => dom_id(haiku, 'change_fav'))
  end
  
  def favorite_image_tag(method)
    image_tag(METHOD_TEXT[method][:image_url], :alt => METHOD_TEXT[method][:name])
  end
end