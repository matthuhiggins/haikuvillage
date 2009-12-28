class Favorite < ActiveRecord::Base
  belongs_to :haiku, :counter_cache => :favorited_count
  belongs_to :author, :counter_cache => :favorites_count
  
  after_create do |fave|
    Author.update_counters(fave.haiku.author, :favorited_count_week => 1, :favorited_count_total => 1)
  end
  
  before_destroy do |fave|
    Author.decrement_counter(:favorited_count_total, fave.haiku.author)
  end
end