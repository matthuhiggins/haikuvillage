class User < ActiveRecord::Base
  has_many :favorites, :through => :haiku_favorites, :source => :haiku
  has_many :haiku_favorites
  has_many :haikus
  
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_presence_of :password
end
