class HaikuFavorite < ActiveRecord::Base
  belongs_to :haiku
  belongs_to :author, :counter_cache => :favorites_count
  
  after_create   { |fav| Haiku.update_counters(fav.haiku_id, :favorited_count_week => 1, :favorited_count_total => 1) }
  before_destroy { |fav| Haiku.update_counters(fav.haiku_id, :favorited_count_week => -1, :favorited_count_total => -1) }
end