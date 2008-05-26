class HaikuFavorite < ActiveRecord::Base
  belongs_to :haiku
  belongs_to :author, :counter_cache => :favorites_count
  
  after_create { |record| record.update_haiku_cache(1) }
  before_destroy { |record| record.update_haiku_cache(-1) }
  
  def update_haiku_cache(value)
    Haiku.update_counters(haiku.id, :favorited_count_week => value, :favorited_count_total => value)
  end
end