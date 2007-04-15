class Group < ActiveRecord::Base
  acts_as_ferret :fields => [:name, :description]
  
  has_many :group_haikus
  has_many :haikus, :through => :group_haikus
  
  has_many :group_users, :dependent => :delete_all
  has_many :users, :through => :group_users
end
