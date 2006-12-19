class School < ActiveRecord::Base
  has_many :school_haikus
  has_many :school_users
  has_many :haikus, :through => :school_haikus
  has_many :users, :through => :school_users
end