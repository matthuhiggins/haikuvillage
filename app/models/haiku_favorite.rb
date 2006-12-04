class HaikuFavorite < ActiveRecord::Base
  belongs_to :haiku
  belongs_to :user
end