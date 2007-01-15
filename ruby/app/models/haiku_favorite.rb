class HaikuFavorite < ActiveRecord::Base
  belongs_to :haiku, :counter_cache => true
  belongs_to :user
end