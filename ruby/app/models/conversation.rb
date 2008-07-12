class Conversation < ActiveRecord::Base
  has_many :haikus
  has_one :flickr_inspiration
end