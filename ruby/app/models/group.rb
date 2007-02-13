class Group < ActiveRecord::Base
  has_many :group_haikus
  has_many :haikus, :through => :group_haikus
  
  has_many :group_users
  has_many :users, :through => :group_users
end
