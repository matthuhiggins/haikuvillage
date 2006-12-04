class HaikuTag < ActiveRecord::Base
  belongs_to :haiku
  belongs_to :tag, :counter_cache => true
end