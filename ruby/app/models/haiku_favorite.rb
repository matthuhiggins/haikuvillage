class HaikuFavorite < ActiveRecord::Base
  belongs_to :haiku
  belongs_to :author, :counter_cache => :favorites_count
  
  after_create do |fave|
    Haiku.update_counters(fave.haiku, :favorited_count_week => 1, :favorited_count_total => 1)
    Author.update_counters(fave.haiku.author, :favorited_count_week => 1, :favorited_count_total => 1)
  end
  
  before_destroy do |fave|
    Haiku.decrement_counter(:favorited_count_total, fave.haiku)
    Author.decrement_counter(:favorited_count_total, fave.haiku.author)
  end
end