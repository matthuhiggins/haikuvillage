class Group < ActiveRecord::Base
  has_many :haikus
  has_many :memberships
  has_many :authors, :through => :memberships
  
  validates_presence_of :name
end