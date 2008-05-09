module FavoritesHelper
  METHOD_TEXT = {
    :put => "Add favorite",
    :delete => "Remove favorite"
  }
  
  def favorite_div(haiku)
    content_tag(:div, change_favorite_link(haiku), :id => dom_id(haiku, 'fav'))
  end
  
  def change_favorite_link(haiku, method = nil)
    method ||= current_user.favorites.include?(haiku) ? :delete : :put
    value = link_to_remote METHOD_TEXT[method], :url => haiku_favorites_url(haiku), :method => method, :update => dom_id(haiku, 'fav')
    logger.debug(value)
    value
  end
  
  def add_favorite_link(haiku)
    change_favorite_link(haiku, :put)
  end
  
  def remove_favorite_link(haiku)
    change_favorite_link(haiku, :delete)
  end
end