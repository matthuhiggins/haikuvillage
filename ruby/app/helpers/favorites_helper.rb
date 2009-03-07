module FavoritesHelper
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
      link_to_remote('Favorite',
          :url => favorite_path(haiku),
          :method => method,
          :update => dom_id(haiku, 'change_fav'),
          :html => {:class => favorite_class(method)})
    end
  
    def favorite_class(method)
      method == :put ? 'icon not-favorite' : 'icon favorite'
    end
end