class HaikuFavorite < ActiveRecord::Base
  belongs_to :haiku, :counter_cache => :favorited_count
  belongs_to :user, :counter_cache => :favorites_count
end